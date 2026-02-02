$ErrorActionPreference = "Stop"

$BaseDir = $PSScriptRoot
if (-not $BaseDir) { $BaseDir = Get-Location }

# Try current dir first, then parent dir (for shared bin/lib)
if (Test-Path (Join-Path $BaseDir "bin")) {
    $Root = $BaseDir
}
elseif (Test-Path (Join-Path (Join-Path $BaseDir "..") "bin")) {
    $Root = Join-Path $BaseDir ".."
}
else {
    $Root = $BaseDir
}

$BinDir = Join-Path $Root "bin"
$LibDir = Join-Path $Root "lib"

$CloudflaredPath = Join-Path $BinDir "cloudflared.exe"
$LogFile = Join-Path $BaseDir "tunnel.log"
$NoVncWebDir = Join-Path $LibDir "noVNC"

# Cleanup
Write-Host "Cleaning up..."
Stop-Process -Name "cloudflared" -ErrorAction SilentlyContinue
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*websockify*" } | ForEach-Object { 
    Stop-Process -Id $_.ProcessId -ErrorAction SilentlyContinue 
}
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
$PythonArgs = "/c python -u -m websockify --verbose --web `"$NoVncWebDir`" 6080 127.0.0.1:5900 > `"$WebsockifyLog`" 2>&1"
$WebsockifyProcess = Start-Process -FilePath "cmd" -ArgumentList $PythonArgs -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 3

$ProxyTest = Test-NetConnection -ComputerName 127.0.0.1 -Port 6080 -WarningAction SilentlyContinue
if (-not $ProxyTest.TcpTestSucceeded) {
    Write-Error "Websockify failed to start. Check $WebsockifyLog."
    Stop-Process -Id $WebsockifyProcess.Id -ErrorAction SilentlyContinue
    exit 1
}
Write-Host "Proxy OK."

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
    Write-Host "Press Ctrl+C to stop."
    
    try {
        while ($true) { Start-Sleep -Seconds 1 }
    }
    catch {}
}
else {
    Write-Host "FAILED. Check log:"
    if (Test-Path $LogFile) { Get-Content $LogFile -Tail 5 }
}

Stop-Process -Id $WebsockifyProcess.Id -ErrorAction SilentlyContinue
Stop-Process -Id $TunnelProcess.Id -ErrorAction SilentlyContinue
Write-Host "Stopped"
