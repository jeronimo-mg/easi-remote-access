# setup_lite.ps1 - Install dependencies for Windows Lite Mode (ttyd)
$ErrorActionPreference = "Stop"

$BaseDir = $PSScriptRoot
if (-not $BaseDir) { $BaseDir = Get-Location }
$BinDir = Join-Path $BaseDir "bin"
if (-not (Test-Path $BinDir)) { New-Item -ItemType Directory -Path $BinDir | Out-Null }

$TtydUrl = "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.win32.exe"
$TtydPath = Join-Path $BinDir "ttyd.exe"

Write-Host "Downloading ttyd (Web Terminal)..."
try {
    # Keep the file name simple
    Invoke-WebRequest -Uri $TtydUrl -OutFile $TtydPath
    Write-Host "Success: $TtydPath" -ForegroundColor Green
}
catch {
    Write-Error "Failed to download ttyd: $_"
    exit 1
}

Write-Host ""
Write-Host "Setup Complete."
Write-Host "You can now run .\start_lite.ps1"
