# 🚀 ClickTop-Windows

User-friendly remote desktop for Windows 11.

## ⚡ Quick Start

1. **Double-click** the `CLICK_TO_START.bat` file.
2. Wait for the URL to appear in the terminal.
3. Open the URL and enter your VNC password.

*Note: Requires TightVNC Server installed and running on port 5900 with "Allow Loopback connections" enabled.*

## 🛠️ Tech Stack

* **Powershell** orchestration.
* **noVNC** (via Websockify).
* **Cloudflare Tunnel**.

## 🛡️ Black Screen Guard (Auto-Recovery)

This version includes an intelligent **Black Screen Guard**:

1. When you connect, a popup appears on the server screen ("I CAN SEE THE SCREEN!").
2. If nobody clicks it within **10 seconds** (because the screen is black for you), the computer will **automatically force-reboot**.
3. This clears the video driver state and restores access.

## 🚀 Auto-Start (Persistence)

To make the remote desktop start automatically when Windows boots (essential for the Auto-Recovery to work):

1. Open PowerShell in the `windows/` folder.
2. Run: `powershell -ExecutionPolicy Bypass -File install_autostart.ps1`

## 🔧 Troubleshooting

### 1. Black Screen (Mouse moves but screen is dark)

* **Cause**: TightVNC on Windows 10/11 often fails to capture the screen efficiently using standard methods.
* **Solution**:
    1. Run `windows/fix_black_screen.ps1` to check driver health.
    2. If it says "Degraded" and cannot fix it, **YOU MUST RESTART THE COMPUTER**.
    3. If you haven't installed the driver yet:
        * Go to `drivers/` folder.
        * Run the installer.
        * **Restart**.

* **Note**: If the black screen returns later, **restart the computer**. Restarting the service alone is often not enough to clear the video driver state on Windows 11.

### 2. "Loopback connections are not enabled"

* **Cause**: TightVNC defaults to blocking connections from localhost (which is how this tunnel works).
* **Solution**:
    1. Open **TightVNC Server** settings.
    2. Go to **Access Control** tab.
    3. Check **"Allow loopback connections"**.
    4. Restart the service/server.

### 3. "Another copy of TightVNC is already running"

* **Cause**: A "zombie" process is stuck in the background.
* **Solution**:
  * Open Task Manager and kill `tvnserver.exe`.
  * Or run in terminal: `taskkill /F /IM tvnserver.exe`
  * Open Task Manager and kill `tvnserver.exe`.
  * Or run in terminal: `taskkill /F /IM tvnserver.exe`
  * Then start TightVNC again from the Start Menu.

## 🍃 Lite Mode (CLI First)

To save resources and have a "Black Screen Proof" access, use the Lite Mode (Web Terminal):

### First Time Setup

1. Open PowerShell in `windows/` folder.
2. Run: `.\setup_lite.ps1` (Downloads `ttyd`).

### Starting Lite Mode

1. Run: `.\start_lite.ps1`
2. Open the URL. You will see a PowerShell terminal in your browser.

### Opening the GUI (On Demand)

If you need to see the screen:

1. Inside the Web Terminal, type: `.\Start-Gui.ps1`
2. Wait for the **New Link** to appear.
3. Open the new link in a tab.
4. When done, close the tab and type `.\Stop-Gui.ps1` in the terminal.
