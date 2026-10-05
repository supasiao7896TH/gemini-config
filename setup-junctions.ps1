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

# 3. Setup Junction for Plugins
$targetPlugins = Join-Path $configDir "plugins"
$sourcePlugins = Join-Path $repoRoot "plugins"

if (Test-Path $targetPlugins) {
    $item = Get-Item $targetPlugins
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Write-Host "[=] Junction already exists: $targetPlugins" -ForegroundColor Green
    } else {
        $backupPlugins = Join-Path $configDir "plugins_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Host "[!] Moving existing plugins to $backupPlugins" -ForegroundColor Yellow
        Move-Item -Path $targetPlugins -Destination $backupPlugins
        New-Item -ItemType Junction -Path $targetPlugins -Target $sourcePlugins | Out-Null
        Write-Host "[+] Created Junction: $targetPlugins -> $sourcePlugins" -ForegroundColor Green
    }
} else {
    New-Item -ItemType Junction -Path $targetPlugins -Target $sourcePlugins | Out-Null
    Write-Host "[+] Created Junction: $targetPlugins -> $sourcePlugins" -ForegroundColor Green
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
        if (-not (Test-Path $destPath) -or $Force) {
            Copy-Item -Path $srcPath -Destination $destPath -Force
            Write-Host "[+] Synced $($f.Src) -> $destPath" -ForegroundColor Green
        } else {
            Write-Host "[=] $($f.Src) already exists at destination (use -Force to overwrite)" -ForegroundColor Gray
        }
    }
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Setup Completed Successfully!            " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
