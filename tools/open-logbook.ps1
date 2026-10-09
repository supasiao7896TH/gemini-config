<#
.SYNOPSIS
    Auto-Open PTA1 Shift Workspace & Routine Launcher
.DESCRIPTION
    เปิดไฟล์และเว็บแอปที่จำเป็นสำหรับการปฏิบัติงานกะ PTA1 อัตโนมัติตอน Login PC:
    1. PTA1 Logbook (FM Activity Report) ตรงจาก SharePoint ผ่าน Microsoft Excel Desktop
    2. Plant 1 Daily Consumption (OPS Logsheet ประจำเดือนล่าสุด) บน Drive K:
    3. Plant 1 Product Transfer Monitoring (ประจำเดือนล่าสุด) บน Drive K:
    4. IOW Plant 1 - PTA unit บน Drive K:
    5. Monitor Log Sheet Boardman Web App (Cloudflare Workers)
    6. PTTGC Laro Routines (id=2122, id=2121)
#>

[CmdletBinding()]
param(
    [switch]$WhatIf
)

$enUS = [System.Globalization.CultureInfo]::GetCultureInfo("en-US")
$now = Get-Date
$year = $now.Year
$monthNum = $now.ToString("MM", $enUS)
$monthAbbr = $now.ToString("MMM", $enUS)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Starting PTA1 Shift Workspace & Routine Launcher...     " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# ----------------------------------------------------------
# 1. PTA1 Logbook (SharePoint via Office Protocol)
# ----------------------------------------------------------
$logbookFile = "${monthNum}.${monthAbbr}_${year} PTA1 FM Activity Report.xlsm"
$encodedFolder = [System.Uri]::EscapeDataString("Report FM,BM $year")
$encodedFile = [System.Uri]::EscapeDataString($logbookFile)
$sharepointUrl = "https://pttgcgroup.sharepoint.com/sites/GCMPINtranet/pe/PEDoc/02%20-%20Plant%201/Log%20book%20PTA1/$encodedFolder/$encodedFile"
$excelUri = "ms-excel:ofe|u|$sharepointUrl"

Write-Host "[1/6] Opening PTA1 Logbook : $logbookFile" -ForegroundColor Green
if (-not $WhatIf) {
    Start-Process $excelUri
}

# ----------------------------------------------------------
# 2. Daily Cons for Shift (OPS Logsheet - เดือนล่าสุด)
# ----------------------------------------------------------
$dailyConsFolder = "K:\PE\01-WWT Daily consumption (SM)\02-Daily cons plant 1\$year"
if (Test-Path $dailyConsFolder) {
    # ค้นหาไฟล์เดือนปัจจุบัน เช่น 10-Plant1 Daily Cons for Shift Oct'26-OPS.xlsm
    $targetCons = Get-ChildItem -Path $dailyConsFolder -Filter "${monthNum}-Plant1 Daily Cons for Shift *.xlsm" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $targetCons) {
        # Fallback: ค้นหาไฟล์เดือนล่าสุดที่มีในโฟลเดอร์
        $targetCons = Get-ChildItem -Path $dailyConsFolder -Filter "*-Plant1 Daily Cons for Shift *.xlsm" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
    }
    if ($targetCons) {
        Write-Host "[2/6] Opening Daily Cons    : $($targetCons.Name)" -ForegroundColor Green
        if (-not $WhatIf) { Start-Process $targetCons.FullName }
    } else {
        Write-Warning "[2/6] Daily Cons file not found in $dailyConsFolder"
    }
} else {
    Write-Warning "[2/6] Drive K:\ Daily Cons folder not accessible"
}

# ----------------------------------------------------------
# 3. Product Transfer Monitoring (เดือนล่าสุด)
# ----------------------------------------------------------
$transferFolder = "K:\PE\02-Daily PTA product CAL ( SM )\06-Product transfer\Plant 1\$year"
if (Test-Path $transferFolder) {
    $targetTransfer = Join-Path $transferFolder "P1_Product_Transfer_Monitoring_${year}${monthNum}.xlsm"
    if (-not (Test-Path $targetTransfer)) {
        # Fallback: ค้นหาไฟล์เดือนล่าสุดที่มีในโฟลเดอร์
        $latestTransfer = Get-ChildItem -Path $transferFolder -Filter "P1_Product_Transfer_Monitoring_*.xlsm" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
        if ($latestTransfer) { $targetTransfer = $latestTransfer.FullName }
    }
    if (Test-Path $targetTransfer) {
        Write-Host "[3/6] Opening Product Trans : $(Split-Path $targetTransfer -Leaf)" -ForegroundColor Green
        if (-not $WhatIf) { Start-Process $targetTransfer }
    } else {
        Write-Warning "[3/6] Product Transfer file not found in $transferFolder"
    }
} else {
    Write-Warning "[3/6] Drive K:\ Product Transfer folder not accessible"
}

# ----------------------------------------------------------
# 4. IOW Plant 1 - PTA unit
# ----------------------------------------------------------
$iowCandidates = @(
    "K:\PE\01-WWT Daily consumption (SM)\02-Daily cons plant 1\$year\IOW_Plant 1 - PTA unit.xlsx",
    "K:\PE\02-Daily PTA product CAL ( SM )\06-Product transfer\Plant 1\IOW_Plant 1 - PTA unit.xlsx"
)
$foundIow = $false
foreach ($p in $iowCandidates) {
    if (Test-Path $p) {
        Write-Host "[4/6] Opening IOW           : $(Split-Path $p -Leaf)" -ForegroundColor Green
        if (-not $WhatIf) { Start-Process $p }
        $foundIow = $true
        break
    }
}
if (-not $foundIow) {
    Write-Warning "[4/6] IOW file not found on Drive K:\"
}

# ----------------------------------------------------------
# 5 & 6. Web Apps & PTTGC Laro Routines
# ----------------------------------------------------------
$webApps = @(
    @{ Name = "Boardman Log Sheet"; Url = "https://monitor-log-sheet-boardman.supasiao.workers.dev/" },
    @{ Name = "Laro Routine 2122";  Url = "https://pttgclaro.pttgcgroup.com/#/routine;id=2122;parentId=845;plantId=841" },
    @{ Name = "Laro Routine 2121";  Url = "https://pttgclaro.pttgcgroup.com/#/routine;id=2121;parentId=846;plantId=841" }
)

Write-Host "[5-6/6] Opening Web Applications..." -ForegroundColor Green
foreach ($app in $webApps) {
    Write-Host "        - $($app.Name)" -ForegroundColor Cyan
    if (-not $WhatIf) {
        Start-Process $app.Url
        Start-Sleep -Milliseconds 400
    }
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  All Workspace files and tabs launched successfully!     " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
