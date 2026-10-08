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

# Force UTF-8 output encoding for emojis
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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

# Emoji Glyphs via UTF-32 (PowerShell 5.1 safe across all codepages)
$eBattery  = [char]::ConvertFromUtf32(0x1F50B)  # 🔋
$eCalendar = [char]::ConvertFromUtf32(0x1F4C5)  # 📅
$eGem      = [char]::ConvertFromUtf32(0x1F48E)  # 💎

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

# 5. Resolve Quota (5h Quota & Weekly Quota)
$quotaInfo = ""
if ($state -and $state.quota) {
    # 5-Hour Quota & Countdown
    $q5 = $state.quota.'gemini-5h'
    if ($q5 -and $null -ne $q5.remaining_fraction) {
        $pct5 = [math]::Round([double]$q5.remaining_fraction * 100)
        $resetCountdown = ""
        if ($q5.reset_in_seconds -and [double]$q5.reset_in_seconds -gt 0) {
            $totalMins = [math]::Round([double]$q5.reset_in_seconds / 60)
            $hrs = [math]::Floor($totalMins / 60)
            $mins = $totalMins % 60
            $resetCountdown = if ($hrs -gt 0) { " (${hrs}h ${mins}m)" } else { " (${mins}m)" }
        }
        $quotaInfo += $sep + $cAmber + "$eBattery 5h: " + $pct5 + "%" + $resetCountdown + $cReset
    }

    # Weekly Quota
    $qWk = $state.quota.'gemini-weekly'
    if ($qWk -and $null -ne $qWk.remaining_fraction) {
        $pctWk = [math]::Round([double]$qWk.remaining_fraction * 100)
        $quotaInfo += $sep + $cAmber + "$eCalendar Wk: " + $pctWk + "%" + $cReset
    }
}

# 6. Resolve Plan Tier
$tierInfo = ""
$tier = if ($state -and $state.plan_tier) { $state.plan_tier } else { "" }
if ($tier) {
    $tierInfo = $sep + $cCyan + "$eGem " + $tier + $cReset
}

# 7. Assemble Statusline Segments
$brandBadge   = $cBold + $cBlue + "[A(i)CODER]" + $cReset
$modelSegment = $cCyan + $modelDisplay + $cReset
$dirSegment   = $cWhite + $dirName + $cReset

$branchSegment = ""
if ($gitBranch) {
    $branchSegment = $sep + $cGreen + "git:" + $gitBranch + $cReset
}

# Final Output Line
$statusLine = $brandBadge + " " + $modelSegment + $sep + $dirSegment + $branchSegment + $tokenInfo + $quotaInfo + $tierInfo

Write-Output $statusLine
exit 0
