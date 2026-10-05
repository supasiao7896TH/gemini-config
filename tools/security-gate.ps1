<#
.SYNOPSIS
    Antigravity PreToolUse Security Gate for Supasit.A (พี่ A)
    Inspects tool calls on stdin, guards secrets and destructive operations.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "SilentlyContinue"

# Read JSON payload from stdin
$inputRaw = [Console]::In.ReadToEnd()

if (-not $inputRaw) {
    Write-Output '{"decision":"allow"}'
    exit 0
}

try {
    $payload = $inputRaw | ConvertFrom-Json
} catch {
    Write-Output '{"decision":"allow"}'
    exit 0
}

$toolName = $payload.toolCall.name
$args = $payload.toolCall.args

# Extract target command or file path
$targetText = ""
if ($args.CommandLine) { $targetText += " " + $args.CommandLine }
if ($args.AbsolutePath) { $targetText += " " + $args.AbsolutePath }
if ($args.TargetFile) { $targetText += " " + $args.TargetFile }
if ($args.Path) { $targetText += " " + $args.Path }

# 1. Sensitive Secret Files
$secretRegex = '(?i)(\.env(\..+)?|credentials\.json|.*serviceAccount.*\.json|.*firebase-adminsdk.*\.json|.*id_rsa|.*id_ed25519|\.pem|\.key|\.p12|\.pfx)'

# 2. Destructive Operations
$destructiveRegex = '(?i)(git\s+push\s+.*--force|git\s+reset\s+--hard|git\s+clean\s+.*-[a-zA-Z]*f|rm\s+-rf\s+[/~*]|DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE\s+TABLE)'

$isSecret = ($targetText -match $secretRegex)
$isDestructive = ($targetText -match $destructiveRegex)

if ($isSecret -or $isDestructive) {
    # Voice alert
    try {
        (New-Object -ComObject SAPI.SpVoice).Speak('Please approve', 1) | Out-Null
    } catch {}

    $reason = if ($isSecret) {
        "Security Gate: Access to sensitive credentials or secret files requires explicit approval."
    } else {
        "Security Gate: Potentially destructive command detected. Explicit approval required."
    }

    $response = @{
        decision = "force_ask"
        reason = $reason
    } | ConvertTo-Json -Compress

    Write-Output $response
} else {
    Write-Output '{"decision":"allow"}'
}
