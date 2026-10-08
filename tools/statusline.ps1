<#
.SYNOPSIS
    Antigravity CLI Custom Statusline for Supasit.A (พี่ A)
    Brand: A-Class WebCraft | GC-M PTA (Supasit.A Studio)
    Receives session state JSON on stdin and renders an ANSI-colored status bar.
#>

param(
    [Parameter(ValueFromPipeline = $true)]
    [string]$InputObject
)

$ErrorActionPreference = "SilentlyContinue"

# ANSI Color Codes
$e = [char]27
$cReset = "$e[0m"
$cBold  = "$e[1m"
$cBlue  = "$e[38;2;29;78;216m"  # Ink Blue (#1D4ED8)
$cAmber = "$e[38;2;217;119;6m"  # Amber (#D97706)
$cCyan  = "$e[36m"
$cGreen = "$e[32m"
$cGray  = "$e[90m"
$cWhite = "$e[97m"

$sep = " " + $cGray + "|" + $cReset + " "

# Read JSON payload from pipeline or stdin
$inputRaw = ""
try {
    if ($InputObject) {
        $inputRaw = $InputObject
    } elseif ($input) {
        $inputRaw = ($input | Out-String)
    } elseif ([Console]::IsInputRedirected) {
        $inputRaw = [Console]::In.ReadToEnd()
    }
} catch {}

$state = $null
if ($inputRaw) {
    try {
        $state = $inputRaw | ConvertFrom-Json
    } catch {}
}

# 1. Resolve Model Name
$modelDisplay = "Gemini"
if ($state -and $state.model) {
    if ($state.model.display_name) {
        $modelDisplay = $state.model.display_name
    } elseif ($state.model.id) {
        $modelDisplay = $state.model.id
    } elseif ($state.model -is [string]) {
        $modelDisplay = $state.model
    }
}

# 2. Resolve Current Directory / Workspace Name
$cwdPath = if ($state -and $state.cwd) { $state.cwd } else { (Get-Location).Path }
$dirName = Split-Path $cwdPath -Leaf
if (-not $dirName) { $dirName = $cwdPath }

# 3. Resolve Git Branch (cached or fast check)
$gitBranch = ""
try {
    $headFile = Join-Path $cwdPath ".git\HEAD"
    if (Test-Path $headFile) {
        $headContent = Get-Content $headFile -Raw
        if ($headContent -match "ref:\s*refs/heads/(.+)") {
            $gitBranch = $matches[1].Trim()
        }
    }
} catch {}

# Fallback git query if not found from .git folder directly
if (-not $gitBranch) {
    try {
        $gitBranch = (git -C $cwdPath branch --show-current 2>$null)
    } catch {}
}

# 4. Resolve Context / Token Usage
$tokenInfo = ""
if ($state -and $state.context_window) {
    if ($null -ne $state.context_window.used_percentage) {
        $pct = [math]::Round([double]$state.context_window.used_percentage, 0)
        $tokenInfo = $sep + $cAmber + "ctx: " + $pct + "%" + $cReset
    } elseif ($null -ne $state.context_window.total_input_tokens) {
        $tokens = [math]::Round([double]$state.context_window.total_input_tokens / 1000, 1)
        $tokenInfo = $sep + $cAmber + $tokens + "k tok" + $cReset
    }
}

# 5. Assemble Statusline Segments
$brandBadge   = $cBold + $cBlue + "[A(i)CODER]" + $cReset
$modelSegment = $cCyan + $modelDisplay + $cReset
$dirSegment   = $cWhite + $dirName + $cReset

$branchSegment = ""
if ($gitBranch) {
    $branchSegment = $sep + $cGreen + "git:" + $gitBranch + $cReset
}

# Final Output Line
$statusLine = $brandBadge + " " + $modelSegment + $sep + $dirSegment + $branchSegment + $tokenInfo

Write-Output $statusLine
exit 0
