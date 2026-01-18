# 🚀 ClickTop-Linux (Web Desktop)

**ClickTop-Linux** is a lightweight, zero-configuration script to make your Linux desktop accessible via a web browser from anywhere in the world.

It combines **x11vnc** (display capturing), **noVNC** (web client), and **Cloudflare Tunnel** (secure exposure) into a single automatic setup.

## ✨ Features

* **Zero Config**: No router port forwarding required.
* **Browser-Based**: Access your desktop from Chrome, Firefox, Safari on any device (including mobile).
* **Secure**: Uses encrypted Cloudflare Tunnels and VNC password protection.
* **Portable**: Scripts handles dependency downloads locally (noVNC/Cloudflared).

## 📦 Requirements

* A Linux machine (Debian/Ubuntu/Mint recommended).
* `sudo` access (for initial x11vnc installation only).

## ⚡ Quick Start (Windows)

1. **Double-click** the `CLICK_TO_START.bat` file.
2. Wait for the URL to appear in the terminal.
3. Open the URL and enter your VNC password.

*Note: Requires TightVNC Server installed and running on port 5900 with "Allow Loopback connections" enabled.*

## ⚡ Quick Start (Linux)

1. **Run the setup**:

    ```console
    bash setup_tools.sh
    ```

2. **Start**:

    ```console
    bash start.sh
    ```

## 🛠️ Tech Stack

* [x11vnc](https://github.com/LibVNC/x11vnc)
* [noVNC](https://github.com/novnc/noVNC)
* [Cloudflare Tunnel](https://github.com/cloudflare/cloudflared)

## 📄 License

MIT License
