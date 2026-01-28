$WScriptShell = New-Object -ComObject WScript.Shell
$StartupDir = $WScriptShell.SpecialFolders.Item("Startup")
$ShortcutPath = Join-Path $StartupDir "ClickTop-Remote.lnk"

# Params
$BaseDir = (Get-Location).Path
$PsScript = Join-Path $BaseDir "start.ps1"
$TaskName = "ClickTopRemoteDesktop"

if ($args[0] -eq "uninstall") {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "Removed Scheduled Task." -ForegroundColor Yellow
}
else {
    # Create Action: Run PowerShell execution of start.ps1 in hidden mode
    # We run start.ps1 directly to bypass BAT limitations in Scheduler background
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PsScript`"" -WorkingDirectory $BaseDir
    
    # Trigger: At LogOn
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    
    # Settings: Allow run on battery, do not stop if runs long
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0
    
    # Register Task
    # We register it to run as the Current User (Interactive) with Highest Privileges
    # This ensures the GUI (Guard Popup) is visible and UAC is bypassed.
    Register-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -TaskName $TaskName -RunLevel Highest -Force
    
    Write-Host "Installed as High-Privilege Scheduled Task: $TaskName" -ForegroundColor Green
}
