# Start-Gui.ps1 - Helper to launch VNC from within Lite Mode
$ErrorActionPreference = "Stop"

$BaseDir = $PSScriptRoot
if (-not $BaseDir) { $BaseDir = Get-Location }

# We reuse the main start.ps1 logic, but we need to run it in a way that gives us the URL back
# efficiently, without killing our current shell.

# Best way: Launch start.ps1 in a new independent process (Hidden), and read its log?
# Or just replicate the launch logic here for Port 6080.

Write-Host "Launching Graphical Interface..."

# Check dependencies (just call the start.ps1 logic or re-implement?)
# Re-implementing is safer to avoid conflict with the interactive wait loop of start.ps1

$BinDir = Join-Path $BaseDir "bin"
$LibDir = Join-Path $BaseDir "lib"
$CloudflaredPath = Join-Path $BinDir "cloudflared.exe"
$NoVncWebDir = Join-Path $LibDir "noVNC"
$GuiLog = Join-Path $BaseDir "tunnel_gui.log" # Distinct log file
$WebsockifyLog = Join-Path $BaseDir "websockify_gui.log"

# 1. Check/Start VNC (TightVNC needs to be running as Service or User app)
$VncTest = Test-NetConnection -ComputerName 127.0.0.1 -Port 5900 -WarningAction SilentlyContinue
if (-not $VncTest.TcpTestSucceeded) {
    Write-Warning "VNC Server (Port 5900) not accessible. Is TightVNC running?"
    # Try to start it? Usually installed as service.
}

# 2. Start Websockify (Port 6080)
# Check if already running
$ProxyTest = Test-NetConnection -ComputerName 127.0.0.1 -Port 6080 -WarningAction SilentlyContinue
if (-not $ProxyTest.TcpTestSucceeded) {
    Write-Host "Starting Websockify Proxy..."
    $PythonArgs = "/c python -u -m websockify --web `"$NoVncWebDir`" 6080 127.0.0.1:5900 > `"$WebsockifyLog`" 2>&1"
    Start-Process -FilePath "cmd" -ArgumentList $PythonArgs -WindowStyle Hidden
    Start-Sleep -Seconds 3
}

# 3. Start Cloudflare Tunnel #2 (GUI)
Write-Host "creating GUI Tunnel..."
if (Test-Path $GuiLog) { Remove-Item $GuiLog }

# Note: We must not conflict with the existing tunnel. Cloudflare allows multiple instances.
$TunnelArgs = "tunnel --url http://127.0.0.1:6080 --logfile `"$GuiLog`""
Start-Process -FilePath $CloudflaredPath -ArgumentList $TunnelArgs -WindowStyle Hidden

# 4. Fetch URL
$FoundUrl = $null
for ($i = 1; $i -le 15; $i++) {
    Start-Sleep -Seconds 1
    if (Test-Path $GuiLog) {
        $LogContent = Get-Content $GuiLog -Raw
        if ($LogContent -match "https://[a-zA-Z0-9-]+\.trycloudflare\.com") {
            $FoundUrl = $matches[0]
            break
        }
    }
}

if ($FoundUrl) {
    Write-Host ""
    Write-Host ">>> GUI READY <<<" -ForegroundColor Yellow
    Write-Host "Link: $FoundUrl/vnc.html" -ForegroundColor Green
    Write-Host ""
    Write-Host "Open this link in a new tab."
    Write-Host "Run .\Stop-Gui.ps1 when done."
}
else {
    Write-Error "Could not generate GUI link. Check $GuiLog"
}
