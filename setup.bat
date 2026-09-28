@echo off
setlocal
cd /d "%~dp0"

echo ==========================================================
echo    SalesLead CRM - Backend Initial Setup Launcher
echo ==========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"

pause
