# test-excel-tidy.ps1 - tests Invoke-ExcelTidy from open-logbook.ps1 on a PRIVATE hidden Excel.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test-excel-tidy.ps1
#
# Safety: it never touches an Excel you are using. It starts its own hidden instance and
# aborts (changing nothing) if Windows hands back an already-running one. Needs Excel.
# Keep this file ASCII-only (Windows PowerShell 5.1).

$ErrorActionPreference = 'Stop'
$launcher = Join-Path $PSScriptRoot 'open-logbook.ps1'

# pull the function out of the launcher without running the launcher
$ast = [System.Management.Automation.Language.Parser]::ParseFile($launcher, [ref]$null, [ref]$null)
$fn = $ast.Find({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Invoke-ExcelTidy' }, $true)
if (-not $fn) { Write-Host 'FAIL  Invoke-ExcelTidy not found in open-logbook.ps1'; exit 1 }
Invoke-Expression $fn.Extent.Text

Add-Type -Namespace Win -Name U32 -MemberDefinition '[DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);'
$before = @(Get-Process excel -ErrorAction SilentlyContinue | ForEach-Object { $_.Id })
$xl = New-Object -ComObject Excel.Application
# identify OUR instance by its window handle -> process id (never guess from "new processes")
[uint32]$ownPid = 0
[void][Win.U32]::GetWindowThreadProcessId([IntPtr][int]$xl.Hwnd, [ref]$ownPid)
if (($ownPid -eq 0) -or ($before -contains [int]$ownPid)) {
  [void][Runtime.InteropServices.Marshal]::ReleaseComObject($xl)
  Write-Host "ABORT  the call attached to an Excel that was already running (pid $ownPid). Nothing was changed."
  exit 2
}
$mine = @([int]$ownPid)

$bad = 0
function Check([string]$name, [bool]$ok) {
  if ($ok) { Write-Host "  ok    $name" } else { Write-Host "FAIL    $name"; $script:bad++ }
}
$tmp = Join-Path $env:TEMP ("tidy-test-{0}.xlsx" -f [guid]::NewGuid().ToString('N').Substring(0, 8))
try {
  $xl.Visible = $false
  $xl.DisplayAlerts = $false

  $blank = $xl.Workbooks.Add()                   # pristine Book -> must be closed
  $withData = $xl.Workbooks.Add()                # has content -> must stay
  $withData.Worksheets.Item(1).Range('A1').Value2 = 'keep me'
  $twoSheets = $xl.Workbooks.Add()               # extra sheet -> must stay
  [void]$twoSheets.Worksheets.Add()
  $logbook = $xl.Workbooks.Add()                 # becomes "the logbook" by saving under a name
  $logbook.Worksheets.Item(1).Range('A1').Value2 = 'logbook'
  $logbook.SaveAs($tmp)
  $logName = Split-Path $tmp -Leaf

  $blankName = $blank.Name; $dataName = $withData.Name; $twoName = $twoSheets.Name

  # 1) logbook missing from Excel -> nothing may be closed
  $r0 = Invoke-ExcelTidy -Excel $xl -LogbookName 'does-not-exist.xlsm'
  Check 'logbook absent -> LogbookOpen=false and nothing closed' (((-not $r0.LogbookOpen)) -and ($r0.Closed.Count -eq 0) -and ($xl.Workbooks.Count -eq 4))

  # 2) logbook present -> only the pristine blank goes
  $r1 = Invoke-ExcelTidy -Excel $xl -LogbookName $logName -ActivateLogbook
  $names = @($xl.Workbooks | ForEach-Object { $_.Name })
  Check 'pristine blank workbook was closed' ($r1.Closed -contains $blankName)
  Check 'workbook with data was kept' ($names -contains $dataName)
  Check 'workbook with 2 sheets was kept' ($names -contains $twoName)
  Check 'logbook was kept' ($names -contains $logName)
  Check 'logbook is the active workbook' ($xl.ActiveWorkbook.Name -eq $logName)
  Check 'data cell untouched' ([string]$withData.Worksheets.Item(1).Range('A1').Value2 -eq 'keep me')

  # 3) second pass is a no-op
  $r2 = Invoke-ExcelTidy -Excel $xl -LogbookName $logName
  Check 'second pass closes nothing' ($r2.Closed.Count -eq 0)
} finally {
  try { $xl.DisplayAlerts = $false; foreach ($wb in @($xl.Workbooks)) { $wb.Close($false) } } catch {}
  try { $xl.Quit() } catch {}
  try { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($xl) } catch {}
  Start-Sleep -Milliseconds 500
  foreach ($id in $mine) { Stop-Process -Id $id -Force -ErrorAction SilentlyContinue }   # only the instance started here
  Remove-Item $tmp -Force -ErrorAction SilentlyContinue
}

if ($bad -gt 0) { Write-Host "`n$bad check(s) failed"; exit 1 }
Write-Host "`nAll Excel-tidy checks pass"
exit 0
