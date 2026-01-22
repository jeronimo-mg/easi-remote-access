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

## 🔧 Troubleshooting

### 1. Black Screen (Mouse moves but screen is dark)

* **Cause**: TightVNC on Windows 10/11 often fails to capture the screen efficiently using standard methods.
* **Solution**: Install the included **DfMirage Mirror Driver**.
    1. Go to the `drivers/` folder in this repository.
    2. Run `dfmirage-setup-2.0.301.exe`.
    3. Install it and **restart your computer** (Essential).
    4. TightVNC will automatically use it to capture the screen.
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
  * Then start TightVNC again from the Start Menu.
