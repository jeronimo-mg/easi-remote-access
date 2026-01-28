$WScriptShell = New-Object -ComObject WScript.Shell
$StartupDir = $WScriptShell.SpecialFolders.Item("Startup")
$ShortcutPath = Join-Path $StartupDir "ClickTop-Remote.lnk"

# Params
$BaseDir = (Get-Location).Path
$PsScript = Join-Path $BaseDir "start.ps1"
# We will use the SAME script, but different logic could be applied.
# Actually, start.ps1 combines both. We need to split duties or have start.ps1 be smart.
# For simplicity:
# Task 1 (Service): Runs start.ps1 as SYSTEM. This brings up the network.
# Task 2 (Guard): Runs guard_monitor.ps1 as USER. This handles the popup.

$ServiceTaskName = "ClickTop-Service"
$GuardTaskName = "ClickTop-Guard"

if ($args[0] -eq "uninstall") {
    Unregister-ScheduledTask -TaskName $ServiceTaskName -Confirm:$false -ErrorAction SilentlyContinue
    Unregister-ScheduledTask -TaskName $GuardTaskName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "Removed Scheduled Tasks." -ForegroundColor Yellow
}
else {
    # --- 1. SERVICE TASK (System, At Boot) ---
    # Runs the main logic (Tunnel, VNC Proxy)
    $ActionService = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PsScript`"" -WorkingDirectory $BaseDir
    $TriggerService = New-ScheduledTaskTrigger -AtStartup
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0
    
    Register-ScheduledTask -Action $ActionService -Trigger $TriggerService -Settings $Settings -TaskName $ServiceTaskName -User "System" -RunLevel Highest -Force
    Write-Host "Installed Service Task (System/Boot): $ServiceTaskName" -ForegroundColor Green
    
    # --- 2. GUARD TASK (User, At Logon) ---
    # Runs a dedicated monitor script that only cares about the popup
    $GuardScript = Join-Path $BaseDir "guard_monitor.ps1"
    $ActionGuard = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$GuardScript`"" -WorkingDirectory $BaseDir
    $TriggerGuard = New-ScheduledTaskTrigger -AtLogOn
    
    # Run as Interactive User
    $Principal = New-ScheduledTaskPrincipal -UserId (measure-object -inputobject "" | select -expandproperty SID).ToString() -LogonType Interactive
    Register-ScheduledTask -Action $ActionGuard -Trigger $TriggerGuard -Settings $Settings -TaskName $GuardTaskName -Principal $Principal -Force
    Write-Host "Installed Guard Task (User/Logon): $GuardTaskName" -ForegroundColor Green
}
