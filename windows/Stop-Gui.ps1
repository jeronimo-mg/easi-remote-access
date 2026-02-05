# Stop-Gui.ps1 - Cleanup GUI components to save resources
$ErrorActionPreference = "SilentlyContinue"

Write-Host "Stopping GUI..."

# 1. Kill the GUI specific Tunnel
# How to distinguish from Lite Tunnel?
# We can find process by command line arg? Cloudflare doesn't make this easy.
# Brute force approach: Kill ALL cloudflared processes EXCEPT the one running port 8080?
# Easier: Just kill all cloudflared. (But that kills our Terminal session! Bad.)

# Better way:
# In start_lite.ps1, we kept the process handle.
# But Start-Gui.ps1 is a separate script. It doesn't know about start_lite's process.

# Alternative: Start-Gui.ps1 saves the PID of the process it started.
$BaseDir = $PSScriptRoot
if (-not $BaseDir) { $BaseDir = Get-Location }
$GuiLog = Join-Path $BaseDir "tunnel_gui.log"

# Getting sophisticated: Find cloudflared processes, check command line for "6080".
$Procs = Get-CimInstance Win32_Process | Where-Object { $_.Name -eq "cloudflared.exe" -and $_.CommandLine -like "*:6080*" }
if ($Procs) {
    $Procs | ForEach-Object { 
        Stop-Process -Id $_.ProcessId -Force 
        Write-Host "Stopped Tunnel (PID $($_.ProcessId))"
    }
}
else {
    Write-Warning "No GUI Tunnel found."
}

# 2. Stop Websockify (Python/Cmd)
$PyProcs = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*websockify*" -and $_.CommandLine -like "*6080*" }
if ($PyProcs) {
    $PyProcs | ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force
        Write-Host "Stopped Websockify (PID $($_.ProcessId))"
    }
}

Write-Host "GUI Stopped. Terminal stays alive."
