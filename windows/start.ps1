$ErrorActionPreference = "Stop"

$BaseDir = Get-Location

# Try current dir first, then parent dir (for shared bin/lib)
if (Test-Path (Join-Path $BaseDir "bin")) {
    $Root = $BaseDir
}
elseif (Test-Path (Join-Path (Join-Path $BaseDir "..") "bin")) {
    $Root = Join-Path $BaseDir ".."
}
else {
    $Root = $BaseDir # Fallback, likely will fail but let setup_tools handle it or error later
}

$BinDir = Join-Path $Root "bin"
$LibDir = Join-Path $Root "lib"

$CloudflaredPath = Join-Path $BinDir "cloudflared.exe"
$LogFile = Join-Path $BaseDir "tunnel.log"
$NoVncWebDir = Join-Path $LibDir "noVNC"

# 0. Cleanup previous sessions
Write-Host "Cleaning up..."
Stop-Process -Name "cloudflared" -ErrorAction SilentlyContinue
Get-Process python -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*websockify*" } | Stop-Process -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1



Write-Host "Checking VNC..."
$VncTest = Test-NetConnection -ComputerName 127.0.0.1 -Port 5900 -WarningAction SilentlyContinue
if (-not $VncTest.TcpTestSucceeded) {
    Write-Error "VNC Server not found on port 5900. Please start TightVNC."
    exit 1
}
Write-Host "VNC OK."

$WebsockifyLog = Join-Path $BaseDir "websockify.log"
if (Test-Path $WebsockifyLog) { Remove-Item $WebsockifyLog }

Write-Host "Starting Proxy..."
# Start websockify with redirection to log file so we can monitor connections
$PythonArgs = "/c python -m websockify --web `"$NoVncWebDir`" 6080 127.0.0.1:5900 > `"$WebsockifyLog`" 2>&1"
$WebsockifyProcess = Start-Process -FilePath "cmd" -ArgumentList $PythonArgs -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 3

# Verify Port 6080
$ProxyTest = Test-NetConnection -ComputerName 127.0.0.1 -Port 6080 -WarningAction SilentlyContinue
if (-not $ProxyTest.TcpTestSucceeded) {
    Write-Error "Websockify failed to start on port 6080. Check $WebsockifyLog."
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
    Write-Host "Monitoring connections... (Press Ctrl+C to stop)"
    
    # Monitoring Loop
    $CurrentLine = 0
    try {
        while ($true) {
            Start-Sleep -Seconds 1
            
            if (Test-Path $WebsockifyLog) {
                $Logs = Get-Content $WebsockifyLog -Tail 5
                
                # Check for new connection patterns from websockify output
                # Pattern often: " 1: 127.0.0.1: Plain non-SSL (ws://) WebSocket connection"
                foreach ($line in $Logs) {
                    if ($line -match "WebSocket connection" -and $line -notmatch "closed") {
                        # Trigger Guard if not already running
                        $GuardProcess = Get-Process -Name "powershell" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*guard.ps1*" }
                        if (-not $GuardProcess) {
                            Write-Host "New client connected! Triggering Black Screen Guard..." -ForegroundColor Cyan
                            Start-Process -FilePath "powershell" -ArgumentList "-ExecutionPolicy Bypass -File `"$BaseDir\guard.ps1`"" -WindowStyle Normal
                            # Sleep to accept the connection fully
                            Start-Sleep -Seconds 5
                        }
                    }
                }
            }
        }
    }
    catch {
        # Ctrl+C or forcing close
    }
}
else {
    Write-Host "FAILED. Check log:"
    if (Test-Path $LogFile) { Get-Content $LogFile -Tail 5 }
}

Stop-Process -Id $WebsockifyProcess.Id -ErrorAction SilentlyContinue
Stop-Process -Id $TunnelProcess.Id -ErrorAction SilentlyContinue
Write-Host "Stopped"

