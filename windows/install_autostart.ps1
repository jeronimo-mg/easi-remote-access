$WScriptShell = New-Object -ComObject WScript.Shell
$StartupDir = $WScriptShell.SpecialFolders.Item("Startup")
$ShortcutPath = Join-Path $StartupDir "ClickTop-Remote.lnk"

# Params
$BaseDir = (Get-Location).Path
$BatFile = Join-Path $BaseDir "CLICK_TO_START.bat"

if ($args[0] -eq "uninstall") {
    if (Test-Path $ShortcutPath) {
        Remove-Item $ShortcutPath
        Write-Host "Removed from Startup." -ForegroundColor Yellow
    }
}
else {
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $BatFile
    $Shortcut.WorkingDirectory = $BaseDir
    $Shortcut.IconLocation = "shell32.dll,13"
    $Shortcut.Description = "ClickTop Remote Desktop"
    $Shortcut.Save()
    Write-Host "Installed to Startup: $ShortcutPath" -ForegroundColor Green
}
