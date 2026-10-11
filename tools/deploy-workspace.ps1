# deploy-workspace.ps1 - publish the PTA1 login launcher to the shared folder every user reads.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\deploy-workspace.ps1
#
# Why: this PC is used by several people (one shift each). The repo lives inside ONE user's
# profile, which the others cannot read, so the launcher that runs at login must live in
# C:\ProgramData\PTA1-Workspace. This script is the only thing that writes there:
#   * copies open-logbook.ps1 and setup-user-workspace.bat (byte for byte, then verifies hash)
#   * re-creates PTA1-Workspace.lnk (what each user copies into their own Startup folder)
#   * lets BUILTIN\Users append to open-logbook.log ONLY (the script stays read-only for them)
#   * removes enable-for-all-users.bat (needs admin and would start the launcher for every
#     profile on the PC, not just the shift users)
# Needs no admin rights when run by the owner of the folder. Every failure is reported, none
# is swallowed. Keep this file ASCII-only: Windows PowerShell 5.1 reads BOM-less files as ANSI.

[CmdletBinding()]
param(
  [string]$Dest = 'C:\ProgramData\PTA1-Workspace',
  [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$src = $PSScriptRoot
$failed = 0

function Say([string]$m, [string]$c = 'Gray') { Write-Host $m -ForegroundColor $c }
function Fail([string]$m) { $script:failed++; Say "  [FAIL] $m" 'Red' }

Say '== PTA1 workspace deploy ==' 'Cyan'
Say "   from: $src"
Say "   to  : $Dest"

if (-not (Test-Path $Dest)) {
  if ($WhatIf) { Say "  [dry] would create $Dest" } else { New-Item -ItemType Directory -Path $Dest -Force | Out-Null }
}

# 1. copy the files and verify the copy
foreach ($name in @('open-logbook.ps1', 'setup-user-workspace.bat')) {
  $from = Join-Path $src $name
  $to = Join-Path $Dest $name
  if (-not (Test-Path $from)) { Fail "missing in repo: $name"; continue }
  if ($WhatIf) { Say "  [dry] would copy $name"; continue }
  try {
    Copy-Item -Path $from -Destination $to -Force
    $h1 = (Get-FileHash $from).Hash
    $h2 = (Get-FileHash $to).Hash
    if ($h1 -eq $h2) { Say ("  [ok]   {0}  {1}" -f $name, $h1.Substring(0, 12)) 'Green' }
    else { Fail "$name copied but hash differs" }
  } catch { Fail "$name : $($_.Exception.Message)" }
}

# 2. the shortcut each user copies into their own Startup folder
$lnk = Join-Path $Dest 'PTA1-Workspace.lnk'
$script = Join-Path $Dest 'open-logbook.ps1'
if ($WhatIf) { Say '  [dry] would write PTA1-Workspace.lnk' }
else {
  try {
    $sh = New-Object -ComObject WScript.Shell
    $s = $sh.CreateShortcut($lnk)
    $s.TargetPath = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $s.Arguments = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -File "' + $script + '"'
    $s.WorkingDirectory = $Dest
    $s.WindowStyle = 7
    $s.Description = 'PTA1 Shift Workspace Auto-Launcher'
    $s.Save()
    Say '  [ok]   PTA1-Workspace.lnk' 'Green'
  } catch { Fail "shortcut: $($_.Exception.Message)" }
}

# 3. log file: create it and let Users (S-1-5-32-545, language independent) modify it
$log = Join-Path $Dest 'open-logbook.log'
if ($WhatIf) { Say '  [dry] would grant Users modify on open-logbook.log' }
else {
  try {
    if (-not (Test-Path $log)) { New-Item -ItemType File -Path $log -Force | Out-Null }
    $out = & icacls.exe $log /grant '*S-1-5-32-545:(M)' 2>&1
    if ($LASTEXITCODE -ne 0) { throw ($out | Out-String).Trim() }
    Say '  [ok]   open-logbook.log writable by Users (script stays read-only)' 'Green'
  } catch { Fail "log ACL: $($_.Exception.Message)" }
}

# 4. retire the all-users installer
$old = Join-Path $Dest 'enable-for-all-users.bat'
if (Test-Path $old) {
  if ($WhatIf) { Say '  [dry] would remove enable-for-all-users.bat' }
  else {
    try { Remove-Item $old -Force; Say '  [ok]   removed enable-for-all-users.bat' 'Green' }
    catch { Fail "remove enable-for-all-users.bat: $($_.Exception.Message)" }
  }
}

if (-not (Test-Path (Join-Path $Dest 'AAA PTA1 GCMP.pdi'))) {
  Say '  [warn] AAA PTA1 GCMP.pdi is not in the shared folder - the launcher falls back to each user''s Desktop' 'Yellow'
}

if ($failed -gt 0) { Say "`n$failed step(s) failed" 'Red'; exit 1 }
Say "`nDeployed. Each shift user runs  $Dest\setup-user-workspace.bat  once." 'Green'
exit 0
