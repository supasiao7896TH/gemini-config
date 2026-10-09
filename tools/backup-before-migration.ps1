<#
.SYNOPSIS
    Pre-Migration Backup Script สำหรับพี่ A (Supasit.A)
.DESCRIPTION
    สำรองข้อมูลโปรเจกต์ โค้ดที่ยังไม่ได้ commit และการตั้งค่า AI/Dotfiles เข้าสู่ OneDrive ก่อน IT เปลี่ยนเครื่อง PC ในวันที่ 30
#>

[CmdletBinding()]
param(
    [string]$BackupDestination = "$env:USERPROFILE\OneDrive - PTT Global Chemical Public Company Limited\PC_Migration_Backup_2026"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   SUPASIT.A - PRE-MIGRATION BACKUP HELPER (2026)         " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. ตรวจสอบปลายทาง OneDrive
if (-not (Test-Path $BackupDestination)) {
    Write-Host "[+] Creating Backup directory in OneDrive: $BackupDestination" -ForegroundColor Green
    New-Item -ItemType Directory -Path $BackupDestination -Force | Out-Null
} else {
    Write-Host "[=] Target Backup directory: $BackupDestination" -ForegroundColor Gray
}

# 2. ตรวจสอบ Git Status และเตือนโปรเจกต์ที่ยังไม่ Commit/Push
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

# 3. สำรองโฟลเดอร์สำคัญเข้า OneDrive
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

# สำรองโฟลเดอร์ Projects หลัก (ตัด node_modules ออกเพื่อให้เร็วและประหยัดพื้นที่คลาวด์)
if (Test-Path $projectsDir) {
    $projectsDest = Join-Path $BackupDestination "A(i)CODER2025TH"
    Write-Host " [*] Backing up Projects to $projectsDest (excluding node_modules)..." -ForegroundColor Cyan
    robocopy $projectsDir $projectsDest /E /R:1 /W:1 /MT:8 /XD node_modules | Out-Null
    Write-Host " [+] Successfully backed up Projects to OneDrive!" -ForegroundColor Green
}

# 4. สรุปผล
Write-Host "`n[3/3] Backup Complete!" -ForegroundColor Green
Write-Host "ไฟล์สำรองทั้งหมดจัดเก็บไว้ที่:" -ForegroundColor Yellow
Write-Host "$BackupDestination" -ForegroundColor White
Write-Host "กรุณาตรวจสอบว่า OneDrive ซิงค์ไฟล์ขึ้น Cloud ครบทุกไฟล์เรียบร้อยค่ะ!`n" -ForegroundColor Green
