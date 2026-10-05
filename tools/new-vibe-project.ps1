# ==========================================================
# New-VibeProject.ps1
# Supasit.A Vibe Coding Project Scaffolder for Antigravity CLI
# Author: Supasit.A (พี่ A)
# ==========================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Project name (alphanumeric, hyphens, underscores)")]
    [ValidatePattern('^[a-zA-Z0-9_\-]+$')]
    [string]$ProjectName,

    [Parameter(Position = 1, HelpMessage = "Destination directory path (default: current directory)")]
    [string]$Path = (Get-Location).Path,

    [switch]$NoGit,
    [switch]$OpenCode,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# 1. Resolve Template Path
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

if (-not (Test-Path (Join-Path $repoRoot "design-lab\starter-multifile"))) {
    $candidates = @(
        "C:\Users\26007294\A(i)CODER2025TH\gemini-config",
        "$env:USERPROFILE\A(i)CODER2025TH\gemini-config",
        "$env:USERPROFILE\.gemini\config"
    )
    foreach ($c in $candidates) {
        if (Test-Path (Join-Path $c "design-lab\starter-multifile")) {
            $repoRoot = $c
            break
        }
    }
}

$templateDir = Join-Path $repoRoot "design-lab\starter-multifile"
if (-not (Test-Path $templateDir)) {
    Write-Error "Template directory not found at: $templateDir"
    return
}

# 2. Check Target Directory
$targetDir = Join-Path $Path $ProjectName
if (Test-Path $targetDir) {
    if (-not $Force) {
        Write-Error "Target directory already exists: $targetDir. Use -Force to overwrite."
        return
    }
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [New-VibeProject] Scaffolding Supasit.A Vibe Project     " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Project:     $ProjectName" -ForegroundColor Yellow
Write-Host " Target:      $targetDir" -ForegroundColor Yellow
Write-Host " Template:    $templateDir" -ForegroundColor Yellow
Write-Host ""

# 3. Create Target Directory and Copy Template Files
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# Copy visible items
Copy-Item -Path (Join-Path $templateDir "*") -Destination $targetDir -Recurse -Force

# Copy hidden items (.github, .husky, .gitignore, .prettierrc, etc.)
Get-ChildItem -Path $templateDir -Force | Where-Object { $_.Name -like ".*" } | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $targetDir -Recurse -Force
}
Write-Host "[+] Copied starter-multifile template" -ForegroundColor Green

# 4. Customize package.json
$pkgPath = Join-Path $targetDir "package.json"
if (Test-Path $pkgPath) {
    $pkgJson = Get-Content -Path $pkgPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $pkgJson.name = $ProjectName.ToLower()
    $pkgJson.description = "$ProjectName - Supasit.A Studio Web App"
    $pkgJson.version = "0.1.0"
    $updatedJson = $pkgJson | ConvertTo-Json -Depth 10
    [IO.File]::WriteAllText($pkgPath, $updatedJson, [Text.Encoding]::UTF8)
    Write-Host "[+] Updated package.json (name: $($pkgJson.name))" -ForegroundColor Green
}

# 5. Inject AGENTS.md for AI Context & Rules
$agentsMdSrc = Join-Path $repoRoot "plugins\user-profile\rules\AGENTS.md"
if (-not (Test-Path $agentsMdSrc)) {
    $agentsMdSrc = Join-Path $repoRoot "AGENTS.md"
}
if (Test-Path $agentsMdSrc) {
    $agentsMdDest = Join-Path $targetDir "AGENTS.md"
    Copy-Item -Path $agentsMdSrc -Destination $agentsMdDest -Force
    Write-Host "[+] Injected AGENTS.md (Supasit.A standard & persona)" -ForegroundColor Green
}

# 6. Initialize Git Repository
if (-not $NoGit) {
    try {
        Push-Location $targetDir
        git init -b main 2>&1 | Out-Null
        git add . 2>&1 | Out-Null
        git commit -m "chore: scaffold $ProjectName from Supasit.A starter-multifile" 2>&1 | Out-Null
        Write-Host "[+] Initialized Git repository (main branch + initial commit)" -ForegroundColor Green
    } catch {
        Write-Warning "Git initialization encountered an issue: $_"
    } finally {
        Pop-Location
    }
}

# 7. Optional VS Code Launch
if ($OpenCode) {
    Write-Host "[+] Launching VS Code..." -ForegroundColor Green
    Start-Process "code" -ArgumentList "`"$targetDir`""
}

# 8. Success Report
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host " Project '$ProjectName' scaffolded successfully!         " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host " Next steps to start Vibe Coding:" -ForegroundColor Cyan
Write-Host "   1. cd `"$targetDir`"" -ForegroundColor White
Write-Host "   2. npm install" -ForegroundColor White
Write-Host "   3. npm run dev" -ForegroundColor White
Write-Host "   4. a  (or agy) to launch Antigravity CLI" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Green
