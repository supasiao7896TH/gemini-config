Set WshShell = CreateObject("WScript.Shell")
scriptPath = WshShell.ExpandEnvironmentStrings("%USERPROFILE%") & "\A(i)CODER2025TH\gemini-config\tools\open-logbook.ps1"
WshShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & scriptPath & """", 0, False
