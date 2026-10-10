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
    7. AAA PTA1 GCMP.pdi (OSIsoft PI ProcessBook) จาก Desktop
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

$logFile = "C:\ProgramData\PTA1-Workspace\open-logbook.log"

function Log-Message {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logLine = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "INFO"    { Write-Host $Message -ForegroundColor Green }
        "WARN"    { Write-Warning $Message }
        "TITLE"   { Write-Host $Message -ForegroundColor Cyan }
        "SUB"     { Write-Host $Message -ForegroundColor Yellow }
        default   { Write-Host $Message }
    }
    
    try {
        Add-Content -Path $logFile -Value $logLine -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch {}
}

# Trim log file if it exceeds 300 lines
if (Test-Path $logFile) {
    try {
        $existingLines = Get-Content -Path $logFile -ErrorAction SilentlyContinue
        if ($existingLines.Count -gt 300) {
            $existingLines | Select-Object -Last 150 | Set-Content -Path $logFile -Encoding UTF8 -Force
        }
    } catch {}
}

Log-Message "==========================================================" "TITLE"
Log-Message "   Starting PTA1 Shift Workspace & Routine Launcher...     " "SUB"
Log-Message "==========================================================" "TITLE"

# ----------------------------------------------------------
# Pre-Check: Network & Drive K: Availability (Wait up to 15s)
# ----------------------------------------------------------
if (-not (Test-Path "K:\")) {
    Log-Message "Drive K:\ not immediately detected. Waiting for network mount..." "SUB"
    $waited = 0
    $maxWait = 15
    while (-not (Test-Path "K:\") -and ($waited -lt $maxWait)) {
        Start-Sleep -Seconds 2
        $waited += 2
        Log-Message "Waiting for Drive K:\ ... ($waited/${maxWait}s)" "SUB"
    }
    if (Test-Path "K:\") {
        Log-Message "Drive K:\ connected successfully after ${waited}s." "INFO"
    } else {
        Log-Message "Drive K:\ still not accessible after ${maxWait}s timeout." "WARN"
    }
}

# ----------------------------------------------------------
# 1. PTA1 Logbook (SharePoint via Office Protocol)
# ----------------------------------------------------------
$logbookFile = "${monthNum}.${monthAbbr}_${year} PTA1 FM Activity Report.xlsm"
$encodedFolder = [System.Uri]::EscapeDataString("Report FM,BM $year")
$encodedFile = [System.Uri]::EscapeDataString($logbookFile)
$sharepointUrl = "https://pttgcgroup.sharepoint.com/sites/GCMPINtranet/pe/PEDoc/02%20-%20Plant%201/Log%20book%20PTA1/$encodedFolder/$encodedFile"
$excelUri = "ms-excel:ofe|u|$sharepointUrl"

Log-Message "[1/6] Opening PTA1 Logbook : $logbookFile" "INFO"
if (-not $WhatIf) {
    Start-Process $excelUri
    Start-Sleep -Milliseconds 1500
}

# ----------------------------------------------------------
# 2. Daily Cons for Shift (OPS Logsheet - เดือนล่าสุด)
# ----------------------------------------------------------
$dailyConsFolder = "K:\PE\01-WWT Daily consumption (SM)\02-Daily cons plant 1\$year"
if (-not (Test-Path $dailyConsFolder)) {
    # Fallback to previous year folder if new year folder does not exist yet
    $dailyConsFolder = "K:\PE\01-WWT Daily consumption (SM)\02-Daily cons plant 1\$($year - 1)"
}

if (Test-Path $dailyConsFolder) {
    # ค้นหาไฟล์เดือนปัจจุบัน เช่น 10-Plant1 Daily Cons for Shift Oct'26-OPS.xlsm
    $targetCons = Get-ChildItem -Path $dailyConsFolder -Filter "${monthNum}-Plant1 Daily Cons for Shift *.xlsm" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $targetCons) {
        # Fallback: ค้นหาไฟล์เดือนล่าสุดที่มีในโฟลเดอร์
        $targetCons = Get-ChildItem -Path $dailyConsFolder -Filter "*-Plant1 Daily Cons for Shift *.xlsm" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
    }
    if ($targetCons) {
        Log-Message "[2/6] Opening Daily Cons    : $($targetCons.Name)" "INFO"
        if (-not $WhatIf) {
            Start-Process $targetCons.FullName
            Start-Sleep -Milliseconds 1500
        }
    } else {
        Log-Message "[2/6] Daily Cons file not found in $dailyConsFolder" "WARN"
    }
} else {
    Log-Message "[2/6] Drive K:\ Daily Cons folder not accessible" "WARN"
}

# ----------------------------------------------------------
# 3. Product Transfer Monitoring (เดือนล่าสุด)
# ----------------------------------------------------------
$transferFolder = "K:\PE\02-Daily PTA product CAL ( SM )\06-Product transfer\Plant 1\$year"
if (-not (Test-Path $transferFolder)) {
    # Fallback to previous year folder if new year folder does not exist yet
    $transferFolder = "K:\PE\02-Daily PTA product CAL ( SM )\06-Product transfer\Plant 1\$($year - 1)"
}

if (Test-Path $transferFolder) {
    $targetTransfer = Join-Path $transferFolder "P1_Product_Transfer_Monitoring_${year}${monthNum}.xlsm"
    if (-not (Test-Path $targetTransfer)) {
        # Fallback: ค้นหาไฟล์เดือนล่าสุดที่มีในโฟลเดอร์
        $latestTransfer = Get-ChildItem -Path $transferFolder -Filter "P1_Product_Transfer_Monitoring_*.xlsm" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
        if ($latestTransfer) { $targetTransfer = $latestTransfer.FullName }
    }
    if (Test-Path $targetTransfer) {
        Log-Message "[3/6] Opening Product Trans : $(Split-Path $targetTransfer -Leaf)" "INFO"
        if (-not $WhatIf) {
            Start-Process $targetTransfer
            Start-Sleep -Milliseconds 1500
        }
    } else {
        Log-Message "[3/6] Product Transfer file not found in $transferFolder" "WARN"
    }
} else {
    Log-Message "[3/6] Drive K:\ Product Transfer folder not accessible" "WARN"
}

# ----------------------------------------------------------
# 4. IOW Plant 1 - PTA unit
# ----------------------------------------------------------
$iowCandidates = @(
    "K:\PE\01-WWT Daily consumption (SM)\02-Daily cons plant 1\$year\IOW_Plant 1 - PTA unit.xlsx",
    "K:\PE\01-WWT Daily consumption (SM)\02-Daily cons plant 1\$($year - 1)\IOW_Plant 1 - PTA unit.xlsx",
    "K:\PE\02-Daily PTA product CAL ( SM )\06-Product transfer\Plant 1\IOW_Plant 1 - PTA unit.xlsx"
)
$foundIow = $false
foreach ($p in $iowCandidates) {
    if (Test-Path $p) {
        Log-Message "[4/6] Opening IOW           : $(Split-Path $p -Leaf)" "INFO"
        if (-not $WhatIf) {
            Start-Process $p
            Start-Sleep -Milliseconds 1500
        }
        $foundIow = $true
        break
    }
}
if (-not $foundIow) {
    Log-Message "[4/6] IOW file not found on Drive K:\" "WARN"
}

# ----------------------------------------------------------
# 5 & 6. Web Apps & PTTGC Laro Routines
# ----------------------------------------------------------
$webApps = @(
    @{ Name = "Boardman Log Sheet"; Url = "https://monitor-log-sheet-boardman.supasiao.workers.dev/" },
    @{ Name = "Laro Routine 2122";  Url = "https://pttgclaro.pttgcgroup.com/#/routine;id=2122;parentId=845;plantId=841" },
    @{ Name = "Laro Routine 2121";  Url = "https://pttgclaro.pttgcgroup.com/#/routine;id=2121;parentId=846;plantId=841" }
)

Log-Message "[5-6/6] Opening Web Applications..." "INFO"
foreach ($app in $webApps) {
    Log-Message "        - $($app.Name)" "SUB"
    if (-not $WhatIf) {
        Start-Process $app.Url
        Start-Sleep -Milliseconds 500
    }
}

# ----------------------------------------------------------
# 7. AAA PTA1 GCMP.pdi (Desktop - PI ProcessBook)
# ----------------------------------------------------------
$pdiDesktopCandidates = @(
    "C:\ProgramData\PTA1-Workspace\AAA PTA1 GCMP.pdi",
    (Join-Path $env:USERPROFILE "OneDrive - PTT Global Chemical Public Company Limited\Other\Desktop\AAA PTA1 GCMP.pdi"),
    (Join-Path $env:USERPROFILE "Desktop\AAA PTA1 GCMP.pdi"),
    ([IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "AAA PTA1 GCMP.pdi"))
)
$pdiDesktopFile = $pdiDesktopCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

$isProcBookRunning = (Get-Process -Name "procbook" -ErrorAction SilentlyContinue) -ne $null
if ($isProcBookRunning) {
    Log-Message "[7/7] PI ProcessBook is already running, skipping launch." "INFO"
} elseif ($pdiDesktopFile) {
    Log-Message "[7/7] Opening PI Display    : $(Split-Path $pdiDesktopFile -Leaf)" "INFO"
    if (-not $WhatIf) {
        Start-Process $pdiDesktopFile
    }
} else {
    Log-Message "[7/7] PI Display file not found on Desktop" "WARN"
}

Log-Message "==========================================================" "TITLE"
Log-Message "  All Workspace files and tabs launched successfully!     " "INFO"
Log-Message "==========================================================" "TITLE"
