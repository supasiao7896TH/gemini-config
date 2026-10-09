<#
.SYNOPSIS
    Pre-Migration Backup Script for Supasit.A
.DESCRIPTION
    Backup projects, uncommitted code, and AI settings to OneDrive before PC replacement.
#>

[CmdletBinding()]
param(
    [string]$BackupDestination = "$env:USERPROFILE\OneDrive - PTT Global Chemical Public Company Limited\PC_Migration_Backup_2026"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   SUPASIT.A - PRE-MIGRATION BACKUP HELPER (2026)         " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Check or create OneDrive destination
if (-not (Test-Path $BackupDestination)) {
    Write-Host "[+] Creating Backup directory in OneDrive: $BackupDestination" -ForegroundColor Green
    New-Item -ItemType Directory -Path $BackupDestination -Force | Out-Null
} else {
    Write-Host "[=] Target Backup directory: $BackupDestination" -ForegroundColor Gray
}

# 2. Check Git status and warn uncommitted/unpushed projects
Write-Host "`n[1/3] Scanning Git repositories in A(i)CODER2025TH..." -ForegroundColor Cyan
$projectsDir = "$env:USERPROFILE\A(i)CODER2025TH"
if (Test-Path $projectsDir) {
    Get-ChildItem $projectsDir -Directory | ForEach-Object {
        $dir = $_.FullName
        if (Test-Path "$dir\.git") {
            $status = git -C $dir status --short
            if ($status) {
                Write-Host " [!] Uncommitted files found in: $($_.Name)" -ForegroundColor Yellow
            } else {
                Write-Host " [OK] Clean: $($_.Name)" -ForegroundColor Green
            }
        } else {
            Write-Host " [!] NO GIT REPO (High Risk): $($_.Name)" -ForegroundColor Red
        }
    }
}

# 3. Backup configuration folders and workspaces
Write-Host "`n[2/3] Backing up critical configuration folders..." -ForegroundColor Cyan
$configItems = @(
    @{ Name = "DotClaude"; Path = "$env:USERPROFILE\.claude" },
    @{ Name = "DotGemini"; Path = "$env:USERPROFILE\.gemini" },
    @{ Name = "DotConfig"; Path = "$env:USERPROFILE\.config" }
)

foreach ($item in $configItems) {
    if (Test-Path $item.Path) {
        $destFolder = Join-Path $BackupDestination $item.Name
        Write-Host " [*] Backing up $($item.Path) -> $destFolder ..." -ForegroundColor Cyan
        robocopy $item.Path $destFolder /E /R:1 /W:1 /MT:8 /XD cache .cache | Out-Null
        Write-Host " [+] Backed up: $($item.Name)" -ForegroundColor Green
    }
}

if (Test-Path $projectsDir) {
    $projectsDest = Join-Path $BackupDestination "A(i)CODER2025TH"
    Write-Host " [*] Backing up Projects to $projectsDest (excluding node_modules)..." -ForegroundColor Cyan
    robocopy $projectsDir $projectsDest /E /R:1 /W:1 /MT:8 /XD node_modules | Out-Null
    Write-Host " [+] Successfully backed up Projects to OneDrive!" -ForegroundColor Green
}

# 4. Finish
Write-Host "`n[3/3] Backup Complete!" -ForegroundColor Green
Write-Host "Backup files stored at:" -ForegroundColor Yellow
Write-Host "$BackupDestination" -ForegroundColor White
Write-Host "Please ensure OneDrive finishes syncing all files to Cloud." -ForegroundColor Green
