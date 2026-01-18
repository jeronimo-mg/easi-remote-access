@echo off
cd /d "%~dp0"
echo Starting Remote Desktop...
powershell -ExecutionPolicy Bypass -File "start.ps1"
pause
