@echo off
chcp 65001 >nul
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync-main.ps1"
set "SYNC_EXIT=%ERRORLEVEL%"
pause
exit /b %SYNC_EXIT%