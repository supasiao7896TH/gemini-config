@echo off
echo ========================================================
echo   PTA1 Shift Workspace - Setup Auto Start for This User
echo ========================================================
echo.

set "SOURCE_LNK=C:\ProgramData\PTA1-Workspace\PTA1-Workspace.lnk"
set "DEST_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

if exist "%SOURCE_LNK%" (
    copy /y "%SOURCE_LNK%" "%DEST_DIR%\" >nul
    echo [SUCCESS] Auto-start configured for your user account!
    echo Next time you log in, all 9 shift files will open automatically.
) else (
    echo [ERROR] Source shortcut not found at %SOURCE_LNK%
)

echo.
pause
