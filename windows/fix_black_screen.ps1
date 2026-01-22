$ErrorActionPreference = "SilentlyContinue"

Write-Host "Diagnosing Video Driver..." -ForegroundColor Cyan

# 1. Reset Mirage Driver
$Mirage = Get-PnpDevice -FriendlyName "Mirage Driver"
if ($Mirage) {
    Write-Host "Found Mirage Driver status: $($Mirage.Status)"
    
    if ($Mirage.Status -eq "Degraded" -or $Mirage.Status -eq "Error") {
        Write-Host "Driver is crashed. Attempting reset..." -ForegroundColor Yellow
        Disable-PnpDevice -InputObject $Mirage -Confirm:$false
        Start-Sleep -Seconds 1
        Enable-PnpDevice -InputObject $Mirage -Confirm:$false
        Start-Sleep -Seconds 1
        
        $Mirage = Get-PnpDevice -FriendlyName "Mirage Driver"
        if ($Mirage.Status -eq "OK") {
            Write-Host "Driver Reset Successful!" -ForegroundColor Green
        }
        else {
            Write-Host "FAILED: Windows refused to restart the driver." -ForegroundColor Red
            Write-Host "Status is still: $($Mirage.Status)" -ForegroundColor Red
            Write-Host "YOU MUST RESTART YOUR COMPUTER TO FIX THIS." -ForegroundColor White -BackgroundColor Red
        }
    }
    else {
        Write-Host "Mirage Driver seems OK." -ForegroundColor Green
    }
}
else {
    Write-Host "Mirage Driver not found." -ForegroundColor Red
}

# 2. Restart VNC Service
Write-Host "Restarting TightVNC Service..."
Stop-Service "tvnserver" -Force
Start-Sleep -Seconds 2
Start-Service "tvnserver"

Write-Host "Done. Please try connecting again." -ForegroundColor Green
Pause
