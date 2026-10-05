# =====================================================================
# Supasit.A (พี่ A) — AI Coder PowerShell Profile Enhancements
# สำหรับวางใน $PROFILE ทั้งเครื่อง Office และเครื่องที่บ้าน
# =====================================================================

# 1. Aliases สำหรับเปิดใช้งาน AI ทันใจ
Set-Alias -Name a -Value agy -ErrorAction SilentlyContinue
Set-Alias -Name c -Value claude -ErrorAction SilentlyContinue

# 2. ฟังก์ชันซิงค์ Antigravity / Gemini CLI Config พร้อมอัปเดต Junctions อัตโนมัติ
function Sync-Gemini {
    $repo = "$env:USERPROFILE\A(i)CODER2025TH\gemini-config"
    if (Test-Path $repo) {
        Write-Host "Syncing gemini-config from GitHub..." -ForegroundColor Cyan
        git -C $repo pull origin main
        powershell -ExecutionPolicy Bypass -File "$repo\setup-junctions.ps1"
    } else {
        Write-Warning "gemini-config repository not found at $repo"
    }
}

# 3. ฟังก์ชันตรวจสุขภาพระบบ Antigravity CLI
function Doctor-Gemini {
    $repo = "$env:USERPROFILE\A(i)CODER2025TH\gemini-config"
    if (Test-Path "$repo\tools\doctor.ps1") {
        powershell -ExecutionPolicy Bypass -File "$repo\tools\doctor.ps1"
    } else {
        Write-Warning "doctor.ps1 not found at $repo\tools\doctor.ps1"
    }
}

# 4. ฟังก์ชันสร้างโปรเจกต์ใหม่ Supasit.A Multi-File Starter
function New-VibeProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ProjectName,
        [Parameter(Position = 1)]
        [string]$Path = (Get-Location).Path,
        [switch]$NoGit,
        [switch]$OpenCode,
        [switch]$Force
    )
    $script = "$env:USERPROFILE\.gemini\config\tools\new-vibe-project.ps1"
    if (-not (Test-Path $script)) {
        $script = "$env:USERPROFILE\A(i)CODER2025TH\gemini-config\tools\new-vibe-project.ps1"
    }
    if (Test-Path $script) {
        & $script @PSBoundParameters
    } else {
        Write-Warning "new-vibe-project.ps1 not found at $script"
    }
}

# 5. ฟังก์ชันซิงค์ Claude Code Config
function Sync-Claude {
    $repo = "$env:USERPROFILE\A(i)CODER2025TH\gemini-config"
    $claudeRepo = "$env:USERPROFILE\A(i)CODER2025TH\claude-config"
    if (Test-Path $claudeRepo) {
        Write-Host "Syncing claude-config from GitHub..." -ForegroundColor Cyan
        git -C $claudeRepo pull origin main
    } else {
        Write-Warning "claude-config repository not found at $claudeRepo"
    }
}
