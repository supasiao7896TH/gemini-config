# =====================================================================
# Supasit.A Studio — Master PC Bootstrap & Restoration Script (2026)
# สคริปต์กู้คืนและตั้งค่าระบบ AI Coder อัตโนมัติ (Antigravity & Claude Code)
# สำหรับใช้งานบน PC เครื่องใหม่ของพี่ A รันเพียงคำสั่งเดียว!
# =====================================================================

[CmdletBinding()]
param(
    [switch]$SkipWinget,
    [switch]$SkipExtensions,
    [switch]$Force
)

$ErrorActionPreference = 'Continue'
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  A-Class WebCraft | Master PC Setup & Restoration Tool   " -ForegroundColor Yellow
Write-Host "  by Supasit.A (พี่ A) - Automated AI Coder Bootstrap     " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$userHome = $env:USERPROFILE
$workspaceDir = Join-Path $userHome "A(i)CODER2025TH"
$geminiRepo = Join-Path $workspaceDir "gemini-config"
$claudeRepo = Join-Path $workspaceDir "claude-config"

# -------------------------------------------------------------
# STEP 1: เตรียมโฟลเดอร์หลักสำหรับจัดเก็บโปรเจกต์
# -------------------------------------------------------------
Write-Host "`n[1/7] Preparing workspace directory..." -ForegroundColor Cyan
if (-not (Test-Path $workspaceDir)) {
    New-Item -ItemType Directory -Path $workspaceDir -Force | Out-Null
    Write-Host "[+] Created workspace: $workspaceDir" -ForegroundColor Green
} else {
    Write-Host "[=] Workspace already exists: $workspaceDir" -ForegroundColor Gray
}

# -------------------------------------------------------------
# STEP 2: ติดตั้งเครื่องมือ Dev พื้นฐานผ่าน Winget
# -------------------------------------------------------------
if (-not $SkipWinget) {
    Write-Host "`n[2/7] Installing core developer tools via Winget..." -ForegroundColor Cyan
    $wingetPackages = @(
        "Git.Git",
        "Microsoft.VisualStudioCode",
        "OpenJS.NodeJS.LTS",
        "Starship.Starship",
        "Microsoft.PowerToys",
        "oschwartz10612.Poppler"
    )

    foreach ($pkg in $wingetPackages) {
        Write-Host " [*] Checking / Installing $pkg ..." -ForegroundColor Gray
        winget install $pkg -e --accept-package-agreements --accept-source-agreements --silent 2>$null
    }
    
    # Refresh PATH environment variable in current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    # ตรวจสอบ Node.js — หาก Winget ลงไม่สำเร็จ (ติดสิทธิ์ Admin) ให้ใช้ระบบสำรอง Portable อัตโนมัติ
    $hasNode = Get-Command node -ErrorAction SilentlyContinue
    if (-not $hasNode) {
        Write-Host " [!] Node.js not detected in PATH. Starting Non-Admin Portable Node.js setup (Plan B)..." -ForegroundColor Yellow
        $nodeDir = "$env:LOCALAPPDATA\Programs\nodejs"
        if (-not (Test-Path $nodeDir)) {
            New-Item -ItemType Directory -Path $nodeDir -Force | Out-Null
        }
        $zipPath = "$env:TEMP\node.zip"
        Write-Host " [*] Downloading official Node.js LTS portable binary..." -ForegroundColor Cyan
        try {
            Invoke-WebRequest -Uri "https://nodejs.org/dist/v22.14.0/node-v22.14.0-win-x64.zip" -OutFile $zipPath
            Expand-Archive -Path $zipPath -DestinationPath "$env:TEMP\node-extract" -Force
            Copy-Item "$env:TEMP\node-extract\node-v22.14.0-win-x64\*" $nodeDir -Recurse -Force
            [System.Environment]::SetEnvironmentVariable("Path", "$nodeDir;" + [System.Environment]::GetEnvironmentVariable("Path", "User"), "User")
            $env:Path = "$nodeDir;$env:Path"
            Write-Host "[+] Non-Admin Portable Node.js ready!" -ForegroundColor Green
        } catch {
            Write-Warning "Could not setup Portable Node.js: $($_.Exception.Message)"
        }
    } else {
        Write-Host "[=] Node.js detected: $(node -v)" -ForegroundColor Green
    }
} else {
    Write-Host "`n[2/7] Skipped Winget installation." -ForegroundColor Yellow
}

# -------------------------------------------------------------
# STEP 3: ตั้งค่า Git Identity & Credential Manager
# -------------------------------------------------------------
Write-Host "`n[3/7] Configuring Git Global Settings..." -ForegroundColor Cyan
git config --global user.name "Supasit Aoothai"
git config --global user.email "supasiao@gmail.com"
git config --global credential.helper manager
Write-Host "[+] Git Identity set: Supasit Aoothai <supasiao@gmail.com>" -ForegroundColor Green

# -------------------------------------------------------------
# STEP 4: ติดตั้ง AI CLI Tools (Antigravity & Claude Code)
# -------------------------------------------------------------
Write-Host "`n[4/7] Installing AI CLI Tools..." -ForegroundColor Cyan

# 4.1 Antigravity CLI (agy)
$agyPath = Join-Path $userHome "AppData\Local\agy\bin\agy.exe"
if (-not (Test-Path $agyPath)) {
    Write-Host " [*] Installing Google Antigravity CLI (agy)..." -ForegroundColor Cyan
    try {
        irm https://antigravity.google/cli/install.ps1 | iex
        Write-Host "[+] Antigravity CLI installed successfully!" -ForegroundColor Green
    } catch {
        Write-Warning "Could not auto-install agy. Please run 'irm https://antigravity.google/cli/install.ps1 | iex' manually."
    }
} else {
    Write-Host "[=] Antigravity CLI (agy) is already installed." -ForegroundColor Green
}

# 4.2 Claude Code CLI (claude)
Write-Host " [*] Checking / Installing Claude Code CLI via npm..." -ForegroundColor Cyan
try {
    npm install -g @anthropic-ai/claude-code
    Write-Host "[+] Claude Code CLI installed successfully!" -ForegroundColor Green
} catch {
    Write-Warning "npm failed or Node.js not yet loaded in PATH. Please restart terminal if needed."
}

# -------------------------------------------------------------
# STEP 5: Clone & Sync Master Repositories
# -------------------------------------------------------------
Write-Host "`n[5/7] Cloning & Syncing Configuration Repositories..." -ForegroundColor Cyan

# 5.1 gemini-config
if (-not (Test-Path $geminiRepo)) {
    Write-Host " [*] Cloning gemini-config..." -ForegroundColor Cyan
    git clone https://github.com/supasiao7896TH/gemini-config.git $geminiRepo
} else {
    Write-Host " [*] Pulling latest gemini-config..." -ForegroundColor Gray
    git -C $geminiRepo pull origin main
}

# 5.2 claude-config
if (-not (Test-Path $claudeRepo)) {
    Write-Host " [*] Cloning claude-config..." -ForegroundColor Cyan
    git clone https://github.com/supasiao7896TH/claude-config.git $claudeRepo
} else {
    Write-Host " [*] Pulling latest claude-config..." -ForegroundColor Gray
    git -C $claudeRepo pull origin main
}

# -------------------------------------------------------------
# STEP 6: เชื่อมต่อ Junctions & Configs (Gemini & Claude)
# -------------------------------------------------------------
Write-Host "`n[6/7] Linking Junctions for Antigravity & Claude Code..." -ForegroundColor Cyan

# 6.1 Run setup-junctions.ps1 for Antigravity
if (Test-Path "$geminiRepo\setup-junctions.ps1") {
    Write-Host " [*] Executing setup-junctions.ps1 for Antigravity..." -ForegroundColor Cyan
    powershell -ExecutionPolicy Bypass -File "$geminiRepo\setup-junctions.ps1" -Force
}

# 6.2 Setup Claude Code (~/.claude) Junctions and Files
$claudeHome = Join-Path $userHome ".claude"
if (-not (Test-Path $claudeHome)) {
    New-Item -ItemType Directory -Path $claudeHome -Force | Out-Null
}

$claudeSkillsTarget = Join-Path $claudeHome "skills"
$claudeSkillsSource = Join-Path $claudeRepo "skills"
if (Test-Path $claudeSkillsTarget) {
    $item = Get-Item $claudeSkillsTarget
    if (-not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        Remove-Item $claudeSkillsTarget -Recurse -Force
        New-Item -ItemType Junction -Path $claudeSkillsTarget -Target $claudeSkillsSource | Out-Null
    }
} else {
    New-Item -ItemType Junction -Path $claudeSkillsTarget -Target $claudeSkillsSource | Out-Null
}
Write-Host "[+] Linked ~/.claude/skills -> $claudeSkillsSource" -ForegroundColor Green

$claudeAgentsTarget = Join-Path $claudeHome "agents"
$claudeAgentsSource = Join-Path $claudeRepo "agents"
if (Test-Path $claudeAgentsTarget) {
    $item = Get-Item $claudeAgentsTarget
    if (-not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        Remove-Item $claudeAgentsTarget -Recurse -Force
        New-Item -ItemType Junction -Path $claudeAgentsTarget -Target $claudeAgentsSource | Out-Null
    }
} else {
    New-Item -ItemType Junction -Path $claudeAgentsTarget -Target $claudeAgentsSource | Out-Null
}
Write-Host "[+] Linked ~/.claude/agents -> $claudeAgentsSource" -ForegroundColor Green

# Copy CLAUDE.md & statusline.ps1
if (Test-Path "$claudeRepo\CLAUDE.md") {
    Copy-Item "$claudeRepo\CLAUDE.md" "$claudeHome\CLAUDE.md" -Force
    Write-Host "[+] Synced CLAUDE.md to $claudeHome" -ForegroundColor Green
}
if (Test-Path "$claudeRepo\statusline.ps1") {
    Copy-Item "$claudeRepo\statusline.ps1" "$claudeHome\statusline.ps1" -Force
    Write-Host "[+] Synced statusline.ps1 to $claudeHome" -ForegroundColor Green
}

# -------------------------------------------------------------
# STEP 7: ติดตั้ง VS Code Extensions ทั้ง 24 ตัว
# -------------------------------------------------------------
if (-not $SkipExtensions) {
    Write-Host "`n[7/7] Installing VS Code Extensions..." -ForegroundColor Cyan
    $extensions = @(
        "anthropic.claude-code",
        "batisteo.vscode-django",
        "benrogerswpg.websearchengine",
        "bradlc.vscode-tailwindcss",
        "christian-kohler.npm-intellisense",
        "codeflow-studio.claude-code-extension",
        "davidanson.vscode-markdownlint",
        "donjayamanne.python-environment-manager",
        "donjayamanne.python-extension-pack",
        "frederiek-pascal.claude-token-tracker-vscode",
        "ganesanchandran.fetch-client",
        "jithurjacob.nbpreviewer",
        "kevinrose.vsc-python-indent",
        "ms-azuretools.vscode-containers",
        "ms-edgedevtools.vscode-edge-devtools",
        "ms-python.debugpy",
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-python.vscode-python-envs",
        "ms-vscode.powershell",
        "njpwerner.autodocstring",
        "vitest.explorer",
        "wholroyd.jinja",
        "yandeu.five-server"
    )

    foreach ($ext in $extensions) {
        Write-Host " [*] Installing extension: $ext" -ForegroundColor Gray
        code --install-extension $ext 2>$null
    }
    Write-Host "[+] All VS Code Extensions installed successfully!" -ForegroundColor Green
}

# -------------------------------------------------------------
# FINAL: ตรวจสุขภาพระบบด้วย Doctor
# -------------------------------------------------------------
Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " Running System Diagnostic (Doctor-Gemini)...             " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
if (Test-Path "$geminiRepo\tools\doctor.ps1") {
    powershell -ExecutionPolicy Bypass -File "$geminiRepo\tools\doctor.ps1"
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host " 🎉 ALL SET! สภาพแวดล้อมพร้อมใช้งาน 100% แล้วค่ะพี่ A!   " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "คำสั่งลัดที่ใช้งานได้ทันทีใน Terminal:" -ForegroundColor Yellow
Write-Host "  a              -> เปิดใช้งาน Antigravity CLI" -ForegroundColor White
Write-Host "  c              -> เปิดใช้งาน Claude Code CLI" -ForegroundColor White
Write-Host "  Sync-Gemini    -> ซิงค์ Config ล่าสุดของ Gemini" -ForegroundColor White
Write-Host "  Doctor-Gemini  -> ตรวจสอบความสมบูรณ์ของระบบ" -ForegroundColor White
