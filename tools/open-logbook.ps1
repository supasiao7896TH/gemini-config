<#
.SYNOPSIS
    Auto-Open PTA1 Shift Workspace & Routine Launcher
.DESCRIPTION
    เปิดไฟล์และเว็บแอปที่จำเป็นสำหรับการปฏิบัติงานกะ PTA1 อัตโนมัติตอน Login PC (รวม 8 รายการ):
    1. PTA1 Logbook (FM Activity Report) ตรงจาก SharePoint ผ่าน Microsoft Excel Desktop
    2. Plant 1 Daily Consumption (OPS Logsheet ประจำเดือนล่าสุด) บน Drive K:
    3. Plant 1 Product Transfer Monitoring (ประจำเดือนล่าสุด) บน Drive K:
    4. IOW Plant 1 - PTA unit บน Drive K:
    5. Monitor Log Sheet Boardman Web App (Cloudflare Workers)
    6. PTTGC Laro Routine id=2122 (PTA-1)
    7. PTTGC Laro Routine id=2121 (PTA-2)
    8. AAA PTA1 GCMP.pdi (OSIsoft PI ProcessBook) จาก Desktop
.PARAMETER WhatIf
    ค้นหา/แสดงรายการอย่างเดียว ไม่เปิดอะไรจริง
.PARAMETER LogbookMonthOffset
    เลื่อนเดือนของ Logbook (SharePoint): 0 = เดือนนี้ (ค่าเริ่มต้น), -1 = เดือนก่อน
    ใช้ช่วงต้นเดือนที่ไฟล์เดือนใหม่ยังไม่ถูกสร้าง — สคริปต์ตรวจไม่ได้เองว่าไฟล์มีหรือยัง
    (SharePoint ตอบ HTTP 403 ทั้งไฟล์ที่มีและไม่มี) จึงไม่เดาถอยเดือนให้อัตโนมัติ
    ตัวอย่าง: powershell -File .\open-logbook.ps1 -LogbookMonthOffset -1
#>

[CmdletBinding()]
param(
    [switch]$WhatIf,
    [int]$LogbookMonthOffset = 0
)

$enUS = [System.Globalization.CultureInfo]::GetCultureInfo("en-US")
$now = Get-Date
$year = $now.Year
$monthNum = $now.ToString("MM", $enUS)
$monthAbbr = $now.ToString("MMM", $enUS)

# Logbook (SharePoint) has its own month so it can be shifted without touching the K: lookups
$lbDate = $now.AddMonths($LogbookMonthOffset)
$lbYear = $lbDate.Year
$lbMonthNum = $lbDate.ToString("MM", $enUS)
$lbMonthAbbr = $lbDate.ToString("MMM", $enUS)

$totalItems = 8

$logFile = "C:\ProgramData\PTA1-Workspace\open-logbook.log"

function Log-Message {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    # shared log (several shift users on one PC): say who ran it
    $logLine = "[$timestamp] [$Level] [$env:USERNAME] $Message"
    
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
$logbookFile = "${lbMonthNum}.${lbMonthAbbr}_${lbYear} PTA1 FM Activity Report.xlsm"
$encodedFolder = [System.Uri]::EscapeDataString("Report FM,BM $lbYear")
$encodedFile = [System.Uri]::EscapeDataString($logbookFile)
$sharepointUrl = "https://pttgcgroup.sharepoint.com/sites/GCMPINtranet/pe/PEDoc/02%20-%20Plant%201/Log%20book%20PTA1/$encodedFolder/$encodedFile"
$excelUri = "ms-excel:ofe|u|$sharepointUrl"

Log-Message "[1/$totalItems] Requesting PTA1 Logbook : $logbookFile" "INFO"
if ($LogbookMonthOffset -eq 0 -and $now.Day -le 2) {
    # Existence on SharePoint cannot be checked from here (HTTP 403 for existing and missing files
    # alike), so no automatic fallback - just make the manual escape hatch visible.
    $prev = $now.AddMonths(-1)
    Log-Message "        Note: first days of the month - if Excel says the file was not found, the new monthly logbook is not created yet. Previous month: -LogbookMonthOffset -1 ($($prev.ToString('MM', $enUS)).$($prev.ToString('MMM', $enUS))_$($prev.Year))" "WARN"
}
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
        Log-Message "[2/$totalItems] Opening Daily Cons    : $($targetCons.Name)" "INFO"
        if (-not $WhatIf) {
            Start-Process $targetCons.FullName
            Start-Sleep -Milliseconds 1500
        }
    } else {
        Log-Message "[2/$totalItems] Daily Cons file not found in $dailyConsFolder" "WARN"
    }
} else {
    Log-Message "[2/$totalItems] Drive K:\ Daily Cons folder not accessible" "WARN"
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
        Log-Message "[3/$totalItems] Opening Product Trans : $(Split-Path $targetTransfer -Leaf)" "INFO"
        if (-not $WhatIf) {
            Start-Process $targetTransfer
            Start-Sleep -Milliseconds 1500
        }
    } else {
        Log-Message "[3/$totalItems] Product Transfer file not found in $transferFolder" "WARN"
    }
} else {
    Log-Message "[3/$totalItems] Drive K:\ Product Transfer folder not accessible" "WARN"
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
        Log-Message "[4/$totalItems] Opening IOW           : $(Split-Path $p -Leaf)" "INFO"
        if (-not $WhatIf) {
            Start-Process $p
            Start-Sleep -Milliseconds 1500
        }
        $foundIow = $true
        break
    }
}
if (-not $foundIow) {
    Log-Message "[4/$totalItems] IOW file not found on Drive K:\" "WARN"
}

# ----------------------------------------------------------
# 5-7. Web Apps & PTTGC Laro Routines
# ----------------------------------------------------------
$webApps = @(
    @{ Name = "Boardman Log Sheet"; Url = "https://monitor-log-sheet-boardman.supasiao.workers.dev/" },
    @{ Name = "Laro Routine 2122";  Url = "https://pttgclaro.pttgcgroup.com/#/routine;id=2122;parentId=845;plantId=841" },
    @{ Name = "Laro Routine 2121";  Url = "https://pttgclaro.pttgcgroup.com/#/routine;id=2121;parentId=846;plantId=841" }
)

$itemNo = 5
foreach ($app in $webApps) {
    Log-Message "[$itemNo/$totalItems] Opening Web App     : $($app.Name)" "INFO"
    $itemNo++
    if (-not $WhatIf) {
        Start-Process $app.Url
        Start-Sleep -Milliseconds 500
    }
}

# ----------------------------------------------------------
# 8. AAA PTA1 GCMP.pdi (Desktop - PI ProcessBook)
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
    Log-Message "[8/$totalItems] PI ProcessBook is already running, skipping launch." "INFO"
} elseif ($pdiDesktopFile) {
    Log-Message "[8/$totalItems] Opening PI Display    : $(Split-Path $pdiDesktopFile -Leaf)" "INFO"
    if (-not $WhatIf) {
        Start-Process $pdiDesktopFile
    }
} else {
    Log-Message "[8/$totalItems] PI Display file not found on Desktop" "WARN"
}

# ----------------------------------------------------------
# 9. Tidy Excel (not counted in $totalItems)
#    When Excel is started by the ms-excel: link it creates a blank "Book1" while the logbook
#    is still loading from SharePoint, and that blank window ends up in front of the logbook.
#    Close ONLY a pristine blank workbook (unsaved, one sheet, A1 empty, no shapes) and bring
#    the logbook to the front. Anything with content is never touched.
# ----------------------------------------------------------
function Invoke-ExcelTidy {
    param(
        [Parameter(Mandatory = $true)] $Excel,
        [Parameter(Mandatory = $true)] [string]$LogbookName,
        [switch]$ActivateLogbook
    )
    $result = @{ LogbookOpen = $false; Closed = @(); Kept = @(); Error = $null }
    try {
        $all = @($Excel.Workbooks)
        $names = @($all | ForEach-Object { $_.Name })
        if ($names -notcontains $LogbookName) { return $result }
        $result.LogbookOpen = $true

        foreach ($wb in $all) {
            if ($wb.Name -notmatch '^Book\d+$') { continue }
            $pristine = $false
            try {
                if (($wb.Path -eq '') -and $wb.Saved -and (-not $wb.ReadOnly) -and ($wb.Worksheets.Count -eq 1)) {
                    $sheet = $wb.Worksheets.Item(1)
                    $isA1 = ($sheet.UsedRange.Address($false, $false) -eq 'A1')
                    $a1Empty = [string]::IsNullOrEmpty([string]$sheet.Range('A1').Formula)
                    if ($isA1 -and $a1Empty -and ($sheet.Shapes.Count -eq 0)) { $pristine = $true }
                }
            } catch { $pristine = $false }

            $wbName = $wb.Name   # read BEFORE Close(): the COM object is gone afterwards
            if ($pristine) { $wb.Close($false); $result.Closed += $wbName }
            else { $result.Kept += $wbName }
        }

        if ($ActivateLogbook) { $Excel.Workbooks.Item($LogbookName).Activate() | Out-Null }
    } catch {
        $result.Error = $_.Exception.Message
    }
    return $result
}

$script:PtaWinReady = $false
try {
    Add-Type -ErrorAction Stop -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;

public static class PtaWin {
    public delegate bool EnumProc(IntPtr h, IntPtr l);
    [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc p, IntPtr l);
    [DllImport("user32.dll")] static extern bool EnumChildWindows(IntPtr h, EnumProc p, IntPtr l);
    [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassName(IntPtr h, StringBuilder s, int n);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
    [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern IntPtr SendMessageTimeout(IntPtr h, uint msg, IntPtr w, StringBuilder l, uint flags, uint timeout, out IntPtr result);

    static string Cls(IntPtr h) { StringBuilder s = new StringBuilder(256); GetClassName(h, s, 256); return s.ToString(); }
    static string Txt(IntPtr h) { StringBuilder s = new StringBuilder(512); GetWindowText(h, s, 512); return s.ToString(); }

    // visible top-level windows owned by the given process ids: "hwnd|pid|class|title"
    public static List<string> Windows(HashSet<uint> pids) {
        List<string> res = new List<string>();
        EnumWindows(delegate (IntPtr h, IntPtr l) {
            uint pid; GetWindowThreadProcessId(h, out pid);
            if (pids.Contains(pid) && IsWindowVisible(h)) {
                res.Add(h.ToInt64() + "|" + pid + "|" + Cls(h) + "|" + Txt(h));
            }
            return true;
        }, IntPtr.Zero);
        return res;
    }

    // text of the static/button/edit controls inside a dialog (read with a short timeout, never blocks)
    public static string ChildTexts(long hwnd) {
        List<string> parts = new List<string>();
        EnumChildWindows(new IntPtr(hwnd), delegate (IntPtr h, IntPtr l) {
            string c = Cls(h);
            if (c == "Static" || c == "Button" || c == "Edit" || c == "DirectUIHWND" || c == "RichEdit20W") {
                StringBuilder sb = new StringBuilder(1024);
                IntPtr r;
                SendMessageTimeout(h, 0x000D, new IntPtr(1024), sb, 0x2, 150, out r);   // WM_GETTEXT, SMTO_ABORTIFHUNG
                string t = sb.ToString().Trim();
                if (t.Length > 0) parts.Add(t);
            }
            return true;
        }, IntPtr.Zero);
        return string.Join(" / ", parts.ToArray());
    }
}
'@
    $script:PtaWinReady = $true
} catch {
    $script:PtaWinReady = $false   # detection unavailable; the launcher itself is unaffected
}

function Get-ExcelWindows {
    # Visible top-level windows of every Excel process, split into main windows and "other" windows
    # (dialogs, splash, prompts). No COM calls: safe to run while Excel shows a modal dialog.
    $res = @{ Main = @(); Dialogs = @() }
    if (-not $script:PtaWinReady) { return $res }
    $set = New-Object 'System.Collections.Generic.HashSet[uint32]'
    foreach ($p in @(Get-Process excel -ErrorAction SilentlyContinue)) { [void]$set.Add([uint32]$p.Id) }
    if ($set.Count -eq 0) { return $res }
    foreach ($row in [PtaWin]::Windows($set)) {
        $f = $row.Split('|', 4)
        $o = [pscustomobject]@{ Hwnd = [int64]$f[0]; Pid = [int]$f[1]; Class = $f[2]; Title = $f[3] }
        if ($o.Class -eq 'XLMAIN') { $res.Main += $o }
        elseif ($o.Class -match '^(XLDESK|EXCEL7|EXCEL6|EXCEL;|MSO_BORDEREFFECT_WINDOW_CLASS|MsoSplash|NetUIHWND|tooltips_class32|SysShadow)$') { }
        else {
            $o | Add-Member -NotePropertyName Texts -NotePropertyValue ([PtaWin]::ChildTexts($o.Hwnd)) -Force
            $res.Dialogs += $o
        }
    }
    return $res
}

function Get-ExcelSnapshot {
    # One line describing Excel right now, for the diagnostic log. Returns @{ Text; HasDialog }.
    # Never talks to Excel through COM while a dialog window is open (a COM call into a modal Excel
    # is exactly what produces "Excel can't do this because a dialog box is open").
    $procs = @(Get-Process excel -ErrorAction SilentlyContinue)
    $p = if ($procs.Count -gt 0) {
        ($procs | ForEach-Object { "{0}@{1}" -f $_.Id, $_.StartTime.ToString('HH:mm:ss') }) -join ','
    } else { 'none' }

    $win = Get-ExcelWindows
    $main = if ($win.Main.Count -gt 0) { ($win.Main | ForEach-Object { "{0}:'{1}'" -f $_.Pid, $_.Title }) -join ' ; ' } else { 'none' }
    $hasDialog = ($win.Dialogs.Count -gt 0)
    $dlg = if ($hasDialog) {
        ($win.Dialogs | ForEach-Object {
            $t = [string]$_.Texts
            if ($t.Length -gt 160) { $t = $t.Substring(0, 160) + '...' }
            "pid={0} class={1} title='{2}' text='{3}'" -f $_.Pid, $_.Class, $_.Title, $t
        }) -join ' ; '
    } else { 'none' }

    $w = '(skipped: a dialog is open)'
    if (-not $hasDialog) {
        try {
            $x = [Runtime.InteropServices.Marshal]::GetActiveObject('Excel.Application')
            $w = (@($x.Workbooks) | ForEach-Object { $_.Name }) -join ' | '
            if (-not $w) { $w = '(no workbook)' }
        } catch {
            $m = ($_.Exception.Message -split "`n")[0]
            $w = '(COM: ' + $m.Substring(0, [Math]::Min(60, $m.Length)) + ')'
        }
    }
    return @{ Text = "excel=[$p] windows=[$main] dialogs=[$dlg] workbooks(first instance)=[$w]"; HasDialog = $hasDialog }
}

function Get-BridgeStatus {
    # The Boardman Excel bridge (scheduled task at logon) is the other thing that starts Excel at login.
    $b = $null
    try {
        $b = Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction Stop |
            Where-Object { $_.CommandLine -match 'excel-bridge' } | Select-Object -First 1
    } catch {}
    $listen = $false
    try { $listen = [bool](Get-NetTCPConnection -LocalPort 5175 -State Listen -ErrorAction Stop) } catch {}
    $bs = if ($b) { "pid=$($b.ProcessId) start=$($b.CreationDate.ToString('HH:mm:ss'))" } else { 'not running' }
    return "bridge=[$bs] port5175=" + $(if ($listen) { 'listening' } else { 'closed' })
}

if ($WhatIf) {
    Log-Message "[diag] would observe Excel for up to 90s (log what opens when) and close a blank Book1 during the first 40s" "SUB"
} else {
    # Phase 1 (0-40s): once the logbook is open, close a PRISTINE blank Book1 (never anything with content).
    # Phase 2 (to 90s): read-only observation, so the next login's log shows the real order of events.
    $obsStart = Get-Date
    $tidyUntil = $obsStart.AddSeconds(40)
    $obsEnd = $obsStart.AddSeconds(90)
    $lastSnap = ''
    $lastChange = $obsStart
    $closedAll = @()
    $logsheetSeenAt = $null
    $logbookSeenAt = $null
    $dialogSeenAt = $null
    $logbookBase = [IO.Path]::GetFileNameWithoutExtension($logbookFile)   # window titles hide the extension

    Log-Message "[diag] t+0s $(Get-BridgeStatus)" "SUB"
    while ((Get-Date) -lt $obsEnd) {
        $elapsed = [int]((Get-Date) - $obsStart).TotalSeconds
        $shot = Get-ExcelSnapshot
        $snap = $shot.Text
        if ($snap -ne $lastSnap) {
            Log-Message "[diag] t+${elapsed}s $snap" "SUB"
            $lastSnap = $snap
            $lastChange = Get-Date
        }
        if ((-not $logsheetSeenAt) -and ($snap -match 'P1-F-2002')) { $logsheetSeenAt = $elapsed }
        if ((-not $logbookSeenAt) -and ($snap.Contains($logbookBase))) { $logbookSeenAt = $elapsed }
        if ($shot.HasDialog -and ($null -eq $dialogSeenAt)) { $dialogSeenAt = $elapsed }

        if (((Get-Date) -lt $tidyUntil) -and (-not $shot.HasDialog)) {   # never poke Excel while it shows a dialog
            try {
                $xl = [Runtime.InteropServices.Marshal]::GetActiveObject('Excel.Application')
                $r = Invoke-ExcelTidy -Excel $xl -LogbookName $logbookFile
                if ($r.Closed.Count -gt 0) {
                    $closedAll += $r.Closed
                    Log-Message "[tidy] t+${elapsed}s closed blank workbook(s): $($r.Closed -join ', ')" "INFO"
                }
            } catch {}   # Excel not started / busy loading: try again next pass
        }

        # settled: past the tidy window, logbook seen, and nothing changed for 30s
        if (((Get-Date) -ge $tidyUntil) -and $logbookSeenAt -and (((Get-Date) - $lastChange).TotalSeconds -ge 30)) { break }
        Start-Sleep -Seconds 3
    }

    $took = [int]((Get-Date) - $obsStart).TotalSeconds
    $closedTxt = if ($closedAll.Count -gt 0) { $closedAll -join ', ' } else { 'none' }
    $lbTxt = if ($null -ne $logbookSeenAt) { "t+${logbookSeenAt}s" } else { 'NEVER' }
    $lsTxt = if ($null -ne $logsheetSeenAt) { "t+${logsheetSeenAt}s" } else { 'NEVER' }
    $dgTxt = if ($null -ne $dialogSeenAt) { "t+${dialogSeenAt}s" } else { 'none' }
    Log-Message "[diag] done after ${took}s: logbook seen=$lbTxt | logsheet (P1-F-2002*) seen=$lsTxt | dialog seen=$dgTxt | blank closed=$closedTxt | $(Get-BridgeStatus)" "INFO"
    if ($null -eq $logbookSeenAt) {
        Log-Message "[diag] logbook not seen within ${took}s (note: COM only sees the FIRST Excel instance; check windows=[...] above for the others)" "WARN"
    }
}

Log-Message "==========================================================" "TITLE"
Log-Message "  $totalItems launch requests sent (Windows cannot confirm each app opened)  " "INFO"
Log-Message "==========================================================" "TITLE"
