$ErrorActionPreference = "Stop"

$BaseDir = Get-Location
# Check if we are in 'windows' subdir, if so, use parent for bin/lib to share with linux/root
if ((Split-Path $BaseDir -Leaf) -eq "windows") {
    $RootDir = Join-Path $BaseDir ".."
}
else {
    $RootDir = $BaseDir
}

$BinDir = Join-Path $RootDir "bin"
$LibDir = Join-Path $RootDir "lib"


# Create directories
if (-not (Test-Path $BinDir)) { New-Item -ItemType Directory -Path $BinDir | Out-Null }
if (-not (Test-Path $LibDir)) { New-Item -ItemType Directory -Path $LibDir | Out-Null }

# 1. Download Cloudflare Tunnel (cloudflared.exe)
$CloudflaredPath = Join-Path $BinDir "cloudflared.exe"
if (-not (Test-Path $CloudflaredPath)) {
    Write-Host "⬇️  Downloading cloudflared..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe" -OutFile $CloudflaredPath
}
else {
    Write-Host "✅ cloudflared already exists." -ForegroundColor Green
}

# 2. Setup noVNC
$NoVncDir = Join-Path $LibDir "noVNC"
if (-not (Test-Path $NoVncDir)) {
    Write-Host "⬇️  Cloning noVNC..." -ForegroundColor Cyan
    git clone https://github.com/novnc/noVNC.git $NoVncDir
}
else {
    Write-Host "✅ noVNC already exists." -ForegroundColor Green
}

# 3. Setup Websockify (Node version)
# noVNC includes a node version in utils/websockify (which requires the 'websockify' npm package usually, 
# strictly speaking noVNC contains the client. The server side 'websockify' is needed.
# The easiest way on Windows with Node installed is to use 'npm install -g websockify' or local.
# Let's install it locally in lib/websockify-js

$WebsockifyDir = Join-Path $LibDir "websockify-js"
if (-not (Test-Path $WebsockifyDir)) {
    Write-Host "⬇️  Installing websockify (node)..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $WebsockifyDir | Out-Null
    Push-Location $WebsockifyDir
    npm init -y | Out-Null
    npm install websockify
    Pop-Location
}
else {
    Write-Host "✅ websockify (node module) already exists." -ForegroundColor Green
}

Write-Host "🎉 Setup Complete!" -ForegroundColor Magenta
