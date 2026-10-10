@echo off
echo ===================================================
echo  Installing PTA1-Workspace for ALL USERS...
echo ===================================================
copy /y "C:\ProgramData\PTA1-Workspace\PTA1-Workspace.lnk" "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\"
if %errorlevel% equ 0 (
    echo [SUCCESS] Shortcut installed for ALL USERS successfully!
    echo Removing duplicate shortcut from current user...
    del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\PTA1-Workspace.lnk" 2>nul
    echo Done!
) else (
    echo [ERROR] Failed to install. Please right-click this file and choose "Run as administrator".
)
pause
