# security-gate.ps1 - Antigravity PreToolUse hook (matcher: run_command)
#
# Ported from claude-config/tools/security-gate.ps1 (same rules, same tests) and adapted to
# Antigravity's contract:
#   stdin  : {"toolCall":{"name":"run_command","args":{"CommandLine":"..."}}}
#   stdout : {"decision":"force_ask","reason":"..."}  or  {"decision":"allow"}
#
# It never hard-blocks: the decision is "force_ask" so the user stays in control.
# Fail-open on purpose: unreadable/unparsable input returns "allow" so a session never bricks.
# Run tools/test-security-gate.ps1 after any edit to prove the rules still fire.
#
# Set GATE_SILENT=1 to skip the spoken "Please approve" (the tests do this).
# Keep this file ASCII-only: Windows PowerShell 5.1 reads BOM-less scripts as ANSI.

$ErrorActionPreference = 'Stop'

function Write-Allow { Write-Output '{"decision":"allow"}'; exit 0 }

function Write-Ask([string]$Reason) {
  if ($env:GATE_SILENT -ne '1') {
    try { $v = New-Object -ComObject SAPI.SpVoice; [void]$v.Speak('Please approve', 0) } catch {}   # 0 = synchronous, so the speech is not cut off by process exit
  }
  $out = @{ decision = 'force_ask'; reason = $Reason } | ConvertTo-Json -Compress
  Write-Output $out
  exit 0
}

$text = ''
try {
  $raw = [Console]::In.ReadToEnd()
  if ([string]::IsNullOrWhiteSpace($raw)) { Write-Allow }
  $evt = $raw | ConvertFrom-Json
  $a = $evt.toolCall.args
  if ($null -eq $a) { Write-Allow }
  foreach ($k in @('CommandLine', 'AbsolutePath', 'TargetFile', 'Path')) {
    if ($a.$k) { $text += ' ' + [string]$a.$k }
  }
  if ([string]::IsNullOrWhiteSpace($text)) { Write-Allow }
} catch {
  Write-Allow
}

# --- 1. Secret files --------------------------------------------------------
# A path token must start and end at a boundary so ".environment" / "monkey.keyboard" do not
# match. Template files (.example / .sample / .template / .dist) are allowed.
$b = '(?<![\w.-])'
$e = '(?![\w.-])'
$secretPatterns = @(
  "$b\.env(\.[A-Za-z0-9_-]+)?$e",
  'credentials\.json',
  'serviceAccount[^\s"''`]*\.json',
  'firebase-adminsdk[^\s"''`]*\.json',
  "${b}id_(rsa|ed25519|ecdsa)${e}",
  '\.(pem|p12|pfx|key)(?![\w.-])',
  "$b\.npmrc$e",
  '[\\/]\.aws[\\/]',
  '\.claude[\\/]\.credentials\.json'
)
$templateOk = '\.(example|sample|template|dist)(?![\w-])'

foreach ($p in $secretPatterns) {
  foreach ($m in [regex]::Matches($text, $p, 'IgnoreCase')) {
    if ($m.Value -notmatch $templateOk) {
      # a template suffix right after the match (".env" + ".example") is handled by $e/(\.name)
      Write-Ask 'Security Gate: Access to sensitive credentials or secret files requires explicit approval.'
    }
  }
}

# --- 2. Destructive / outward-facing commands ---------------------------------
$rules = @(
  @{ re = 'git\s+push\b[^\n;|&]*(--force\b|--force-with-lease\b|\s-f\b|\s\+\S)'; why = 'git force-push can overwrite remote history' },
  @{ re = 'git\s+reset\s+--hard';                                              why = 'git reset --hard discards uncommitted work' },
  @{ re = 'git\s+clean\b[^\n;|&]*(\s-\w*f\w*|\s--force)\b';                    why = 'git clean -f deletes untracked files permanently' },
  @{ re = 'git\s+checkout\s+(--\s+)?\.(\s|$)';                                 why = 'git checkout . discards all working-tree changes' },
  @{ re = 'git\s+restore\s+\.(\s|$)';                                          why = 'git restore . discards all working-tree changes' },
  @{ re = 'git\s+branch\s+-D\b';                                               why = 'git branch -D deletes an unmerged branch' },
  @{ re = '\b(DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE\s+TABLE)\b';             why = 'destructive SQL' },
  @{ re = '\bDELETE\s+FROM\s+[\w.\[\]"`]+\s*(;|"|''|$)';                          why = 'DELETE without WHERE removes every row' },
  @{ re = '\b(Remove-Item|ri|del|erase)\b[^\n;|]*\s-r(?:e(?:c(?:u(?:r(?:s(?:e)?)?)?)?)?)?(?!\w)'; why = 'recursive delete' },
  @{ re = '\b(rd|rmdir)\s+/s\b|\bdel\s+/[sfq]\b';                              why = 'recursive delete (cmd)' },
  @{ re = '\bformat\s+[A-Za-z]:';                                              why = 'disk format' },
  @{ re = 'firebase\s+firestore:delete\b';                                     why = 'deletes Firestore data' },
  @{ re = 'wrangler\s+(delete|secret\s+delete)\b';                             why = 'deletes a Cloudflare Worker/secret' },
  @{ re = 'gh\s+repo\s+(delete|edit\b[^\n;|]*--visibility)';                   why = 'changes or deletes a GitHub repo' },
  @{ re = 'npm\s+publish\b';                                                   why = 'npm publish is public and hard to undo' },
  @{ re = '\bSet-ExecutionPolicy\b';                                           why = 'changes the PowerShell execution policy (persistent security setting)' },
  @{ re = '\b(curl|wget|irm|iwr|Invoke-WebRequest|Invoke-RestMethod)\b[^\n;]*\|\s*(sh|bash|iex|Invoke-Expression)\b'; why = 'pipes a remote script straight into a shell' }
)
foreach ($r in $rules) {
  if ($text -match "(?i)$($r.re)") {
    Write-Ask ("Security Gate: {0}. Explicit approval required." -f $r.why)
  }
}

# rm with a recursive flag: ask, except plain build-output folders
if ($text -match '(?i)\brm\s+(-\S+\s+)*(-\S*[rR]\S*|--recursive)\b') {
  $safeTargets = '(?i)\brm\s+(-\S+\s+)+((\./)?(node_modules|dist|build|coverage|\.cache|\.vite|\.playwright|test-results)/?\s*)+$'
  if ($text.Trim() -notmatch $safeTargets) {
    Write-Ask 'Security Gate: recursive rm can delete a whole folder tree. Explicit approval required.'
  }
}

Write-Allow
