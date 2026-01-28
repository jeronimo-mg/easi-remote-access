Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Black Screen Check"
$Form.Size = New-Object System.Drawing.Size(400, 200)
$Form.StartPosition = "CenterScreen"
$Form.TopMost = $true
$Form.FormBorderStyle = "FixedDialog"
$Form.ControlBox = $false
$Form.BackColor = [System.Drawing.Color]::DarkRed

$Label = New-Object System.Windows.Forms.Label
$Label.Text = "REMOTE ACCESS DETECTED`n`nIf you can see this screen, CLICK THE BUTTON below.`n`nRebooting in 10 seconds..."
$Label.AutoSize = $false
$Label.Size = New-Object System.Drawing.Size(380, 100)
$Label.Top = 10
$Label.Left = 10
$Label.ForeColor = [System.Drawing.Color]::White
$Label.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$Label.TextAlign = "MiddleCenter"
$Form.Controls.Add($Label)

$Button = New-Object System.Windows.Forms.Button
$Button.Text = "I CAN SEE THE SCREEN! (CANCEL REBOOT)"
$Button.Size = New-Object System.Drawing.Size(300, 50)
$Button.Top = 110
$Button.Left = (400 - 300) / 2 - 10
$Button.BackColor = [System.Drawing.Color]::White
$Button.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$Form.Controls.Add($Button)

$Timer = New-Object System.Windows.Forms.Timer
$Timer.Interval = 1000 # 1 second
$SecondsLeft = 10

$Timer.Add_Tick({
        $script:SecondsLeft--
        $Label.Text = "REMOTE ACCESS DETECTED`n`nIf you can see this screen, CLICK THE BUTTON below.`n`nRebooting in $script:SecondsLeft seconds..."
    
        if ($script:SecondsLeft -le 0) {
            $Timer.Stop()
            $Form.Close()
            Write-Host "TIMEOUT: Black Screen suspected. REBOOTING SYSTEM."
            Restart-Computer -Force
        }
    })

$Button.Add_Click({
        $Timer.Stop()
        Write-Host "USER CONFIRMED: Screen is visible."
        $Form.Close()
    })

$Timer.Start()
[System.Windows.Forms.Application]::Run($Form)
