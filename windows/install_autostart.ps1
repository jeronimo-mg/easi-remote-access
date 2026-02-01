$WScriptShell = New-Object -ComObject WScript.Shell
$StartupDir = $WScriptShell.SpecialFolders.Item("Startup")
$ShortcutPath = Join-Path $StartupDir "ClickTop-Remote.lnk"

# Check for Administrator Privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'."
    exit 1
}

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
    
    try {
        Register-ScheduledTask -Action $ActionService -Trigger $TriggerService -Settings $Settings -TaskName $ServiceTaskName -User "System" -RunLevel Highest -Force -ErrorAction Stop
        Write-Host "Installed Service Task (System/Boot): $ServiceTaskName" -ForegroundColor Green
    }
    catch {
        Write-Host "FAILED to register Service Task: $_" -ForegroundColor Red
    }
    
    # --- 2. GUARD TASK (User, At Logon) ---
    # Runs a dedicated monitor script that only cares about the popup
    $GuardScript = Join-Path $BaseDir "guard_monitor.ps1"
    $ActionGuard = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$GuardScript`"" -WorkingDirectory $BaseDir
    $TriggerGuard = New-ScheduledTaskTrigger -AtLogOn
    
    # Re-register as Interactive User (so Popup works)
    try {
        $CurrentSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
        $Principal = New-ScheduledTaskPrincipal -UserId $CurrentSid -LogonType Interactive -RunLevel Highest
        Register-ScheduledTask -Action $ActionGuard -Trigger $TriggerGuard -Settings $Settings -TaskName $GuardTaskName -Principal $Principal -Force -ErrorAction Stop
        Write-Host "Installed Guard Task (User/Logon): $GuardTaskName" -ForegroundColor Green
    }
    catch {
        Write-Host "FAILED to register Guard Task: $_" -ForegroundColor Red
    }
}

Write-Host "Done. Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
