@echo off
echo ========================================================
echo   PTA1 Shift Workspace - Setup Auto Start for This User
echo ========================================================
echo.
echo Run this ONCE per Windows user (no administrator rights needed).
echo.

set "SHARED=C:\ProgramData\PTA1-Workspace"
set "SOURCE_LNK=%SHARED%\PTA1-Workspace.lnk"
set "DEST_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

if not exist "%SHARED%\open-logbook.ps1" (
    echo [ERROR] Launcher script not found: %SHARED%\open-logbook.ps1
    echo         Ask the owner of the workspace to run tools\deploy-workspace.ps1
    goto :done
)

if exist "%SOURCE_LNK%" (
    copy /y "%SOURCE_LNK%" "%DEST_DIR%\" >nul
    if errorlevel 1 (
        echo [ERROR] Could not copy the shortcut into your Startup folder.
    ) else (
        echo [SUCCESS] Auto-start configured for your user account!
        echo Next time you log in, all 8 shift items (4 files, 3 web pages, 1 PI display) will open automatically.
        echo Log: %SHARED%\open-logbook.log
    )
) else (
    echo [ERROR] Source shortcut not found at %SOURCE_LNK%
)

:done
echo.
pause
