<#
.SYNOPSIS
    Auto-Open Current Month PTA1 Logbook directly in Microsoft Excel Desktop
.DESCRIPTION
    คำนวณเดือนและปีปัจจุบันอัตโนมัติ แล้วเปิดไฟล์ Logbook (PTA1 FM Activity Report)
    ตรงจาก SharePoint GC-M PTA เข้าสู่ Microsoft Excel Desktop พร้อมรองรับ Macro (.xlsm)
    และระบบ AutoSave / Co-authoring ร่วมกับทีมงานกะ
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

# ชื่อไฟล์ประจำเดือนปัจจุบัน เช่น: "10.Oct_2026 PTA1 FM Activity Report.xlsm"
$fileName = "${monthNum}.${monthAbbr}_${year} PTA1 FM Activity Report.xlsm"

# ประกอบ SharePoint URL ของโฟลเดอร์ Report FM,BM ตามปีปัจจุบัน
$encodedFolder = [System.Uri]::EscapeDataString("Report FM,BM $year")
$encodedFile = [System.Uri]::EscapeDataString($fileName)
$sharepointUrl = "https://pttgcgroup.sharepoint.com/sites/GCMPINtranet/pe/PEDoc/02%20-%20Plant%201/Log%20book%20PTA1/$encodedFolder/$encodedFile"

# ใช้ Microsoft Office Protocol (ms-excel:ofe|u|<url>)
# ofe = Open For Edit ตรงเข้าสู่โปรแกรม Microsoft Excel Desktop
$excelUri = "ms-excel:ofe|u|$sharepointUrl"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Opening PTA1 Logbook in Microsoft Excel Desktop...      " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Target File : $fileName" -ForegroundColor Green
Write-Host " Target URL  : $sharepointUrl" -ForegroundColor Gray

if (-not $WhatIf) {
    Start-Process $excelUri
}
