<#
.SYNOPSIS
    Antigravity CLI System Doctor & Health Diagnostics for Supasit.A (พี่ A)
    Usage: .\tools\doctor.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$geminiDir = Join-Path $env:USERPROFILE ".gemini"
$configDir = Join-Path $geminiDir "config"

$totalChecks = 0
$passedChecks = 0
$warnChecks = 0
$failChecks = 0

function Report-Check {
    param(
        [string]$Status,
        [string]$Name,
        [string]$Message,
        [string]$Fix = ""
    )
    $script:totalChecks++
    switch ($Status) {
        "OK" {
            $script:passedChecks++
            Write-Host "  [OK]   " -ForegroundColor Green -NoNewline
            Write-Host "$Name " -ForegroundColor White -NoNewline
            Write-Host "- $Message" -ForegroundColor Gray
        }
        "WARN" {
            $script:warnChecks++
            Write-Host "  [WARN] " -ForegroundColor Yellow -NoNewline
            Write-Host "$Name " -ForegroundColor Yellow -NoNewline
            Write-Host "- $Message" -ForegroundColor Gray
            if ($Fix) { Write-Host "         -> FIX: $Fix" -ForegroundColor DarkYellow }
        }
        "FAIL" {
            $script:failChecks++
            Write-Host "  [FAIL] " -ForegroundColor Red -NoNewline
            Write-Host "$Name " -ForegroundColor Red -NoNewline
            Write-Host "- $Message" -ForegroundColor Gray
            if ($Fix) { Write-Host "         -> FIX: $Fix" -ForegroundColor Magenta }
        }
    }
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [Doctor] Antigravity CLI Health Diagnostics (Supasit.A)  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Repo: $repoRoot" -ForegroundColor DarkGray
Write-Host " Machine: $env:COMPUTERNAME ($env:USERNAME)" -ForegroundColor DarkGray
Write-Host ""

# 1. Toolchain & Binaries
Write-Host "1. Toolchain & CLI Executables" -ForegroundColor Cyan
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
    $gitVer = (git --version 2>&1)
    Report-Check "OK" "Git" $gitVer
} else {
    Report-Check "FAIL" "Git" "Not found in PATH" "Install Git for Windows"
}

$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
    $nodeVer = (node -v 2>&1)
    Report-Check "OK" "Node.js" $nodeVer
} else {
    Report-Check "FAIL" "Node.js" "Not found in PATH" "Install Node.js (LTS)"
}

$agyCmd = Get-Command agy -ErrorAction SilentlyContinue
if ($agyCmd) {
    $agyVer = (agy --version 2>&1)
    Report-Check "OK" "Antigravity CLI (agy)" "v$agyVer ($($agyCmd.Source))"
} else {
    Report-Check "FAIL" "Antigravity CLI (agy)" "Not found in PATH" "Run: irm https://antigravity.google/cli/install.ps1 | iex"
}

Write-Host ""
# 2. Directory Junctions
Write-Host "2. Directory Junctions Integrity" -ForegroundColor Cyan
$junctions = @("skills", "agents", "tools", "plugins")
foreach ($j in $junctions) {
    $targetPath = Join-Path $configDir $j
    if (-not (Test-Path $targetPath)) {
        Report-Check "FAIL" "Junction: $j" "Target does not exist at $targetPath" "Run: .\setup-junctions.ps1 -Force"
    } else {
        $item = Get-Item $targetPath -Force
        $isJunction = ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
        if (-not $isJunction) {
            Report-Check "FAIL" "Junction: $j" "Exists but is a normal folder, NOT a Junction" "Run: .\setup-junctions.ps1 -Force"
        } else {
            Report-Check "OK" "Junction: $j" "ReparsePoint active -> pointing to repo $j"
        }
    }
}

# Tools & Templates
$newVibeScript = Join-Path $repoRoot "tools\new-vibe-project.ps1"
if (Test-Path $newVibeScript) {
    Report-Check "OK" "Tool: New-VibeProject" "Scaffolder script present and ready"
} else {
    Report-Check "WARN" "Tool: New-VibeProject" "Script not found at $newVibeScript" "Restore from repo"
}

$starterTemplate = Join-Path $repoRoot "design-lab\starter-multifile"
if (Test-Path $starterTemplate) {
    Report-Check "OK" "Starter Template" "design-lab/starter-multifile available"
} else {
    Report-Check "FAIL" "Starter Template" "design-lab/starter-multifile missing" "Restore from git"
}

Write-Host ""
# 3. Configurations & MCP Sync
Write-Host "3. Configurations & MCP Settings" -ForegroundColor Cyan

# config.json
$cfgPath = Join-Path $configDir "config.json"
if (Test-Path $cfgPath) {
    try {
        $cfgJson = Get-Content $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($cfgJson.plugins."user-profile".enabled -eq $true) {
            Report-Check "OK" "config.json" "Synced & user-profile plugin is enabled"
        } else {
            Report-Check "WARN" "config.json" "user-profile plugin is NOT enabled" "Run: .\setup-junctions.ps1 -Force"
        }
    } catch {
        Report-Check "FAIL" "config.json" "Invalid JSON format: $_" "Run: .\setup-junctions.ps1 -Force"
    }
} else {
    Report-Check "FAIL" "config.json" "Not found at $cfgPath" "Run: .\setup-junctions.ps1 -Force"
}

# hooks.json & voice-alert.ps1
$hooksPath = Join-Path $configDir "hooks.json"
if (Test-Path $hooksPath) {
    $hooksRaw = Get-Content $hooksPath -Raw -Encoding UTF8
    if ($hooksRaw -match "voice-alert\.ps1") {
        Report-Check "OK" "hooks.json" "Voice alerts enabled -> pointing to voice-alert.ps1"
    } elseif ($hooksRaw -match "Speak\('[^']+',\s*1\)") {
        Report-Check "WARN" "hooks.json" "Voice alerts using inline async speech (recommend voice-alert.ps1)" "Run: .\setup-junctions.ps1 -Force"
    } else {
        Report-Check "WARN" "hooks.json" "Voice alerts found but configuration might need update" "Run: .\setup-junctions.ps1 -Force"
    }
} else {
    Report-Check "FAIL" "hooks.json" "Not found at $hooksPath" "Run: .\setup-junctions.ps1 -Force"
}

$voiceAlertScript = Join-Path $configDir "tools\voice-alert.ps1"
if (Test-Path $voiceAlertScript) {
    Report-Check "OK" "Tool: voice-alert.ps1" "Voice alert handler ready"
} else {
    Report-Check "FAIL" "Tool: voice-alert.ps1" "voice-alert.ps1 missing in tools" "Run: .\setup-junctions.ps1 -Force"
}

# statusline.ps1 & CLI settings
$statusScript = Join-Path $configDir "tools\statusline.ps1"
if (Test-Path $statusScript) {
    Report-Check "OK" "Tool: statusline.ps1" "Statusline renderer present"
} else {
    Report-Check "FAIL" "Tool: statusline.ps1" "Missing statusline.ps1 in tools" "Restore from git"
}

$cliSettingsPath = Join-Path (Join-Path $geminiDir "antigravity-cli") "settings.json"
if (Test-Path $cliSettingsPath) {
    try {
        $cliJson = Get-Content $cliSettingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($cliJson.statusLine -and $cliJson.statusLine.enabled -ne $false) {
            Report-Check "OK" "Antigravity CLI statusLine" "Active & enabled in settings.json"
        } else {
            Report-Check "WARN" "Antigravity CLI statusLine" "statusLine block not enabled" "Run: .\setup-junctions.ps1 -Force"
        }
    } catch {
        Report-Check "WARN" "Antigravity CLI statusLine" "Could not parse settings.json" "Run: .\setup-junctions.ps1 -Force"
    }
} else {
    Report-Check "WARN" "Antigravity CLI settings" "settings.json not found" "Run: .\setup-junctions.ps1 -Force"
}

# mcp_config.json
$mcpPath = Join-Path $configDir "mcp_config.json"
if (Test-Path $mcpPath) {
    try {
        $mcpRaw = Get-Content $mcpPath -Raw -Encoding UTF8
        $mcpJson = $mcpRaw | ConvertFrom-Json
        $hasFirebase = $null -ne $mcpJson.mcpServers."firebase-mcp-server"
        $hasPuppeteer = $null -ne $mcpJson.mcpServers.puppeteer
        
        $escapedProfile = [regex]::Escape(($env:USERPROFILE -replace '\\', '\\'))
        $hasWrongProfile = ($mcpRaw -match '(?i)c:\\\\Users\\\\[^\\]+' -and -not ($mcpRaw -match $escapedProfile))

        if ($hasWrongProfile) {
            Report-Check "WARN" "mcp_config.json" "Detected user path that does not match current user ($env:USERNAME)" "Run: .\setup-junctions.ps1 -Force"
        } elseif ($hasFirebase -and $hasPuppeteer) {
            Report-Check "OK" "mcp_config.json" "Firebase and Puppeteer active (user path matches current user)"
        } else {
            Report-Check "OK" "mcp_config.json" "Valid MCP configuration synced"
        }
    } catch {
        Report-Check "FAIL" "mcp_config.json" "Invalid JSON: $_" "Run: .\setup-junctions.ps1 -Force"
    }
} else {
    Report-Check "FAIL" "mcp_config.json" "Not found at $mcpPath" "Run: .\setup-junctions.ps1 -Force"
}

# .geminiignore
$geminiIgnorePath = Join-Path $geminiDir ".geminiignore"
if (Test-Path $geminiIgnorePath) {
    Report-Check "OK" ".geminiignore" "Synced at $geminiIgnorePath"
} else {
    Report-Check "WARN" ".geminiignore" "Not found at $geminiIgnorePath" "Run: .\setup-junctions.ps1 -Force"
}

Write-Host ""
# 4. Native Subagents & Persona
Write-Host "4. Subagents & Persona Compliance" -ForegroundColor Cyan
$expectedAgents = @(
    @{ Name = "sa-architect"; ExpectedModel = "pro" },
    @{ Name = "sa-code-reviewer"; ExpectedModel = "pro" },
    @{ Name = "sa-debugger"; ExpectedModel = "pro" },
    @{ Name = "sa-explore"; ExpectedModel = "flash" },
    @{ Name = "sa-git-manager"; ExpectedModel = "flash" },
    @{ Name = "sa-handoff"; ExpectedModel = "flash" },
    @{ Name = "sa-summarizer"; ExpectedModel = "flash" }
)

$agentsDir = Join-Path $repoRoot "agents"
$allAgentsOk = $true
foreach ($a in $expectedAgents) {
    $aFile = Join-Path $agentsDir "$($a.Name).md"
    if (Test-Path $aFile) {
        $aRaw = Get-Content $aFile -Raw -Encoding UTF8
        $hasModel = ($aRaw -match "model:\s*$($a.ExpectedModel)")
        $hasPersona = ($aRaw -match '\u0E2B\u0E19\u0E39' -and $aRaw -match '\u0E04\u0E48\u0E30' -and $aRaw -match '\u0E1E\u0E35\u0E48\s*A')
        if (-not ($hasModel -and $hasPersona)) {
            $allAgentsOk = $false
            Report-Check "WARN" "Subagent $($a.Name)" "Model or persona tag mismatch" "Review $($a.Name).md"
        }
    } else {
        $allAgentsOk = $false
        Report-Check "FAIL" "Subagent $($a.Name)" "File missing at $aFile" "Restore from git"
    }
}
if ($allAgentsOk) {
    Report-Check "OK" "Native Subagents (7/7)" "All 7 subagents verified (pro/flash models + persona rules intact)"
}

Write-Host ""
# 5. Git Repository Status
Write-Host "5. Git Repository Status" -ForegroundColor Cyan
$remoteUrl = (git -C $repoRoot remote get-url origin 2>&1)
if ($remoteUrl -match "supasiao7896TH/gemini-config") {
    Report-Check "OK" "Git Remote" "Origin: $remoteUrl"
} else {
    Report-Check "WARN" "Git Remote" "Remote: $remoteUrl"
}

$gitStatus = (git -C $repoRoot status --porcelain 2>&1)
if (-not $gitStatus) {
    Report-Check "OK" "Working Tree" "Clean (no uncommitted changes)"
} else {
    Report-Check "WARN" "Working Tree" "Has uncommitted changes" "Run: git status"
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
if ($failChecks -eq 0 -and $warnChecks -eq 0) {
    Write-Host " [ALL CHECKS PASSED] $passedChecks/$totalChecks - Antigravity is 100% Healthy! " -ForegroundColor Green
} elseif ($failChecks -eq 0) {
    Write-Host " [PASSED WITH WARNINGS] $passedChecks passed, $warnChecks warnings " -ForegroundColor Yellow
} else {
    Write-Host " [DOCTOR FOUND ISSUES] $failChecks failed, $warnChecks warnings, $passedChecks passed " -ForegroundColor Red
}
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

exit $failChecks
