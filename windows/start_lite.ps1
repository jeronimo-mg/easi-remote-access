# start_lite.ps1 - Starts Web Terminal (ttyd) + Cloudflare Tunnel
$ErrorActionPreference = "Stop"

$BaseDir = $PSScriptRoot
if (-not $BaseDir) { $BaseDir = Get-Location }
$BinDir = Join-Path $BaseDir "bin"
$TtydPath = Join-Path $BinDir "ttyd.exe"
$CloudflaredPath = Join-Path $BinDir "cloudflared.exe"
$LogFile = Join-Path $BaseDir "tunnel_lite.log"

if (-not (Test-Path $TtydPath)) {
    Write-Error "ttyd.exe not found. Please run .\setup_lite.ps1 first."
    exit 1
}

# 1. Start ttyd (Terminal Server) on port 8080
Write-Host "Starting Web Terminal (ttyd) on port 8080..."
# -p 8080: Port
# -W: Writable (allows typing)
# powershell.exe: The shell to run
$TtydProcess = Start-Process -FilePath $TtydPath -ArgumentList "-p 8080 -W powershell.exe" -PassThru -WindowStyle Hidden

# 2. Start Cloudflare Tunnel pointing to 8080
Write-Host "Starting Tunnel..."
if (Test-Path $LogFile) { Remove-Item $LogFile }

$TunnelArgs = "tunnel --url http://127.0.0.1:8080 --logfile `"$LogFile`""
$TunnelProcess = Start-Process -FilePath $CloudflaredPath -ArgumentList $TunnelArgs -PassThru -WindowStyle Hidden

Write-Host "Waiting for URL..."
$FoundUrl = $null
for ($i = 1; $i -le 20; $i++) {
    Start-Sleep -Seconds 2
    if (Test-Path $LogFile) {
        $LogContent = Get-Content $LogFile -Raw
        if ($LogContent -match "https://[a-zA-Z0-9-]+\.trycloudflare\.com") {
            $FoundUrl = $matches[0]
            break
        }
    }
}

if ($FoundUrl) {
    Write-Host ""
    Write-Host "SUCCESS (Lite Mode): $FoundUrl" -ForegroundColor Green
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  To see screen: .\Start-Gui.ps1" -ForegroundColor Cyan
    Write-Host "  To stop GUI:   .\Stop-Gui.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press Ctrl+C to stop Terminal."
    
    try {
        while ($true) { Start-Sleep -Seconds 1 }
    }
    catch {}
}
else {
    Write-Error "Failed to get URL. Check $LogFile"
}

# Cleanup on exit
Stop-Process -Id $TtydProcess.Id -ErrorAction SilentlyContinue
Stop-Process -Id $TunnelProcess.Id -ErrorAction SilentlyContinue
