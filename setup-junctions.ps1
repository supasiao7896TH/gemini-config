<#
.SYNOPSIS
    Setup Junctions and Configurations for Google Antigravity / Gemini CLI
    Repository: https://github.com/supasiao7896TH/gemini-config
    Author: Supasit.A (พี่ A)
#>

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$geminiDir = Join-Path $env:USERPROFILE ".gemini"
$configDir = Join-Path $geminiDir "config"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Setting up Gemini Config & Junctions...  " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Ensure Target Directories
if (-not (Test-Path $configDir)) {
    Write-Host "[+] Creating directory: $configDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

# 2. Setup Junction for Skills
$targetSkills = Join-Path $configDir "skills"
$sourceSkills = Join-Path $repoRoot "skills"

if (Test-Path $targetSkills) {
    $item = Get-Item $targetSkills
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Write-Host "[=] Junction already exists: $targetSkills" -ForegroundColor Green
    } else {
        $backupSkills = Join-Path $configDir "skills_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Host "[!] Moving existing skills to $backupSkills" -ForegroundColor Yellow
        Move-Item -Path $targetSkills -Destination $backupSkills
        New-Item -ItemType Junction -Path $targetSkills -Target $sourceSkills | Out-Null
        Write-Host "[+] Created Junction: $targetSkills -> $sourceSkills" -ForegroundColor Green
    }
} else {
    New-Item -ItemType Junction -Path $targetSkills -Target $sourceSkills | Out-Null
    Write-Host "[+] Created Junction: $targetSkills -> $sourceSkills" -ForegroundColor Green
}

# 3. Setup Junction for Agents (Custom Subagents)
$targetAgents = Join-Path $configDir "agents"
$sourceAgents = Join-Path $repoRoot "agents"

if (Test-Path $targetAgents) {
    $item = Get-Item $targetAgents
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Write-Host "[=] Junction already exists: $targetAgents" -ForegroundColor Green
    } else {
        $backupAgents = Join-Path $configDir "agents_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Host "[!] Moving existing agents to $backupAgents" -ForegroundColor Yellow
        Move-Item -Path $targetAgents -Destination $backupAgents
        New-Item -ItemType Junction -Path $targetAgents -Target $sourceAgents | Out-Null
        Write-Host "[+] Created Junction: $targetAgents -> $sourceAgents" -ForegroundColor Green
    }
} else {
    New-Item -ItemType Junction -Path $targetAgents -Target $sourceAgents | Out-Null
    Write-Host "[+] Created Junction: $targetAgents -> $sourceAgents" -ForegroundColor Green
}

# Ensure plugins/user-profile/agents also has a junction for plugin discovery
$pluginUserProfileAgents = Join-Path $repoRoot "plugins\user-profile\agents"
if (-not (Test-Path $pluginUserProfileAgents)) {
    New-Item -ItemType Junction -Path $pluginUserProfileAgents -Target $sourceAgents | Out-Null
    Write-Host "[+] Created Junction: $pluginUserProfileAgents -> $sourceAgents" -ForegroundColor Green
}

# 4. Setup Junction for Tools
$targetTools = Join-Path $configDir "tools"
$sourceTools = Join-Path $repoRoot "tools"

if (Test-Path $targetTools) {
    $item = Get-Item $targetTools
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Write-Host "[=] Junction already exists: $targetTools" -ForegroundColor Green
    } else {
        $backupTools = Join-Path $configDir "tools_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Host "[!] Moving existing tools to $backupTools" -ForegroundColor Yellow
        Move-Item -Path $targetTools -Destination $backupTools
        New-Item -ItemType Junction -Path $targetTools -Target $sourceTools | Out-Null
        Write-Host "[+] Created Junction: $targetTools -> $sourceTools" -ForegroundColor Green
    }
} else {
    New-Item -ItemType Junction -Path $targetTools -Target $sourceTools | Out-Null
    Write-Host "[+] Created Junction: $targetTools -> $sourceTools" -ForegroundColor Green
}

# 5. Setup Junction for Plugins (with fallback if root plugins folder is locked by process)
$targetPlugins = Join-Path $configDir "plugins"
$sourcePlugins = Join-Path $repoRoot "plugins"

$pluginsJunctioned = $false
if (Test-Path $targetPlugins) {
    $item = Get-Item $targetPlugins
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Write-Host "[=] Junction already exists: $targetPlugins" -ForegroundColor Green
        $pluginsJunctioned = $true
    } else {
        try {
            $backupPlugins = Join-Path $configDir "plugins_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Move-Item -Path $targetPlugins -Destination $backupPlugins -ErrorAction Stop
            New-Item -ItemType Junction -Path $targetPlugins -Target $sourcePlugins | Out-Null
            Write-Host "[+] Created Junction: $targetPlugins -> $sourcePlugins" -ForegroundColor Green
            $pluginsJunctioned = $true
        } catch {
            Write-Host "[!] Note: plugins folder is currently locked by a running Antigravity process." -ForegroundColor Yellow
            Write-Host "[+] Falling back to per-plugin folder junctions..." -ForegroundColor Cyan
        }
    }
} else {
    New-Item -ItemType Junction -Path $targetPlugins -Target $sourcePlugins | Out-Null
    Write-Host "[+] Created Junction: $targetPlugins -> $sourcePlugins" -ForegroundColor Green
    $pluginsJunctioned = $true
}

if (-not $pluginsJunctioned) {
    # Junction individual plugins inside plugins folder
    Get-ChildItem -Directory -Path $sourcePlugins | ForEach-Object {
        $pluginName = $_.Name
        $targetSinglePlugin = Join-Path $targetPlugins $pluginName
        $sourceSinglePlugin = $_.FullName

        if (Test-Path $targetSinglePlugin) {
            $pItem = Get-Item $targetSinglePlugin
            if ($pItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                Write-Host "[=] Per-plugin junction already exists: $pluginName" -ForegroundColor Green
            } else {
                $pBackup = Join-Path $targetPlugins "${pluginName}_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                Move-Item -Path $targetSinglePlugin -Destination $pBackup
                New-Item -ItemType Junction -Path $targetSinglePlugin -Target $sourceSinglePlugin | Out-Null
                Write-Host "[+] Created Junction for plugin: $pluginName" -ForegroundColor Green
            }
        } else {
            New-Item -ItemType Junction -Path $targetSinglePlugin -Target $sourceSinglePlugin | Out-Null
            Write-Host "[+] Created Junction for plugin: $pluginName" -ForegroundColor Green
        }
    }
}

# 4. Copy Configurations (Non-destructive)
$filesToCopy = @(
    @{ Src = "config.json"; Dest = Join-Path $configDir "config.json" },
    @{ Src = "hooks.json"; Dest = Join-Path $configDir "hooks.json" },
    @{ Src = "mcp_config.json"; Dest = Join-Path $configDir "mcp_config.json" },
    @{ Src = ".geminiignore"; Dest = Join-Path $geminiDir ".geminiignore" }
)

foreach ($f in $filesToCopy) {
    $srcPath = Join-Path $repoRoot $f.Src
    $destPath = $f.Dest
    if (Test-Path $srcPath) {
        if ($f.Src -eq "mcp_config.json") {
            # Dynamically replace user path with current $env:USERPROFILE for multi-machine portability
            $escapedProfile = $env:USERPROFILE -replace '\\', '\\'
            $content = (Get-Content -Path $srcPath -Raw -Encoding UTF8) -replace '(?i)c:\\\\Users\\\\[^\\]+', $escapedProfile
            if (-not (Test-Path $destPath) -or $Force) {
                [IO.File]::WriteAllText($destPath, $content, [Text.Encoding]::UTF8)
                Write-Host "[+] Synced $($f.Src) (Dynamic User Profile: $env:USERNAME) -> $destPath" -ForegroundColor Green
            } else {
                Write-Host "[=] $($f.Src) already exists at destination (use -Force to overwrite)" -ForegroundColor Gray
            }
        } else {
            if ($f.Src -eq "hooks.json" -or -not (Test-Path $destPath) -or $Force) {
                Copy-Item -Path $srcPath -Destination $destPath -Force
                Write-Host "[+] Synced $($f.Src) -> $destPath" -ForegroundColor Green
            } else {
                Write-Host "[=] $($f.Src) already exists at destination (use -Force to overwrite)" -ForegroundColor Gray
            }
        }
    }
}

# 5. Setup Antigravity CLI statusLine Configuration
$cliSettingsDir = Join-Path $geminiDir "antigravity-cli"
$cliSettingsPath = Join-Path $cliSettingsDir "settings.json"
$statuslineScript = Join-Path $configDir "tools\statusline.ps1"

if (-not (Test-Path $cliSettingsDir)) {
    New-Item -ItemType Directory -Path $cliSettingsDir -Force | Out-Null
}

$statuslineConfig = [ordered]@{
    type = "command"
    command = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$statuslineScript`""
    enabled = $true
}

$cliSettings = $null
if (Test-Path $cliSettingsPath) {
    try {
        $raw = Get-Content -Path $cliSettingsPath -Raw -Encoding UTF8
        if ($raw) {
            $cliSettings = $raw | ConvertFrom-Json
        }
    } catch {
        $cliSettings = $null
    }
}

if (-not $cliSettings) {
    $cliSettings = [PSCustomObject]@{}
}

$hasStatusLine = [bool]($cliSettings.PSObject.Properties['statusLine'])
if (-not $hasStatusLine -or $Force) {
    $cliSettings | Add-Member -NotePropertyName "statusLine" -NotePropertyValue ([PSCustomObject]$statuslineConfig) -Force
    $newJson = $cliSettings | ConvertTo-Json -Depth 10
    [IO.File]::WriteAllText($cliSettingsPath, $newJson, [Text.Encoding]::UTF8)
    Write-Host "[+] Configured statusLine in $cliSettingsPath" -ForegroundColor Green
} else {
    Write-Host "[=] statusLine already configured in $cliSettingsPath (use -Force to overwrite)" -ForegroundColor Gray
}

# 6. Deploy PTA1 Logbook Auto-Start to Windows Startup
$startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$logbookVbs = Join-Path $repoRoot "tools\Open-PTA1-Logbook.vbs"
if ((Test-Path $startupFolder) -and (Test-Path $logbookVbs)) {
    Copy-Item $logbookVbs (Join-Path $startupFolder "Open-PTA1-Logbook.vbs") -Force
    Write-Host "[+] Configured PTA1 Logbook auto-open on Windows Startup" -ForegroundColor Green
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Setup Completed Successfully!            " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
