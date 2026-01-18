$ErrorActionPreference = "Stop"

$BaseDir = Get-Location
$BinDir = Join-Path $BaseDir "bin"
$LibDir = Join-Path $BaseDir "lib"
$CloudflaredPath = Join-Path $BinDir "cloudflared.exe"
$LogFile = Join-Path $BaseDir "tunnel.log"
$NoVncWebDir = Join-Path $LibDir "noVNC"

# 0. Cleanup previous sessions
Write-Host "Cleaning up..."
Stop-Process -Name "cloudflared" -ErrorAction SilentlyContinue
Get-Process python | Where-Object { $_.CommandLine -like "*websockify*" } | Stop-Process -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1


Write-Host "Checking VNC..."
$VncTest = Test-NetConnection -ComputerName 127.0.0.1 -Port 5900 -WarningAction SilentlyContinue
if (-not $VncTest.TcpTestSucceeded) {
    Write-Error "VNC Server not found on port 5900. Please start TightVNC."
    exit 1
}
Write-Host "VNC OK."

Write-Host "Starting Proxy..."
# Use python -m websockify directly.
# We are manually starting it and waiting a bit.
$PythonArgs = "-m websockify --web `"$NoVncWebDir`" 6080 127.0.0.1:5900"
$WebsockifyProcess = Start-Process -FilePath "python" -ArgumentList $PythonArgs -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 3

# Verify Port 6080
$ProxyTest = Test-NetConnection -ComputerName 127.0.0.1 -Port 6080 -WarningAction SilentlyContinue
if (-not $ProxyTest.TcpTestSucceeded) {
    Write-Error "Websockify failed to start on port 6080. It might be crashing or port is in use."
    # Kill if exists
    Stop-Process -Id $WebsockifyProcess.Id -ErrorAction SilentlyContinue
    exit 1
}
Write-Host "Proxy OK on port 6080."

Write-Host "Starting Tunnel..."
if (Test-Path $LogFile) { Remove-Item $LogFile }
$TunnelArgs = "tunnel --url http://127.0.0.1:6080 --logfile `"$LogFile`""
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
    Write-Host "SUCCESS: $FoundUrl/vnc.html" -ForegroundColor Green
    Write-Host ""
    Write-Host "Press Enter to stop..."
    Read-Host
}
else {
    Write-Host "FAILED. Check log:"
    if (Test-Path $LogFile) { Get-Content $LogFile -Tail 5 }
}

Stop-Process -Id $WebsockifyProcess.Id -ErrorAction SilentlyContinue
Stop-Process -Id $TunnelProcess.Id -ErrorAction SilentlyContinue
Write-Host "Stopped"
