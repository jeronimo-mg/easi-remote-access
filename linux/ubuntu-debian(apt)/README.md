# 🚀 ClickTop-Linux (Web Desktop)

**ClickTop-Linux** is a lightweight, zero-configuration script to make your Linux desktop accessible via a web browser from anywhere in the world.

It combines **x11vnc** (display capturing), **noVNC** (web client), and **Cloudflare Tunnel** (secure exposure) into a single automatic setup.

## ✨ Features
*   **Zero Config**: No router port forwarding required.
*   **Browser-Based**: Access your desktop from Chrome, Firefox, Safari on any device (including mobile).
*   **Secure**: Uses encrypted Cloudflare Tunnels and VNC password protection.
*   **Portable**: Scripts handles dependency downloads locally (noVNC/Cloudflared).

## 📦 Requirements
*   A Linux machine (Debian/Ubuntu/Mint recommended).
*   `sudo` access (for initial x11vnc installation only).

## ⚡ Quick Start

1.  **Clone or Download** this repository.
2.  **Run the setup** (downloads portable tools):
    ```console
    bash setup_tools.sh
    ```
3.  **Start the magic**:
    ```console
    bash start.sh
    ```
4.  **Access**: The script will print a unique `https://...` URL. Open it, enter the generated password, and enjoy!

## 🚀 Lite Mode (Terminal Only)
For a resource-efficient experience (low RAM/CPU usage), use the **Lite Mode**. It opens a terminal in your browser via Xpra.

1.  **Setup Lite dependencies**:
    ```console
    bash setup_lite.sh
    ```
2.  **Start Lite Mode**:
    ```console
    bash start_lite.sh
    ```
3.  **Usage**: Open the URL to access the terminal. To run a GUI app (like firefox), just type `firefox &` in the browser terminal!

## 🛑 How to Stop
Press `Ctrl+C` in the terminal or run:
```console
pkill x11vnc
pkill cloudflared
```

## 🛠️ Tech Stack
*   [x11vnc](https://github.com/LibVNC/x11vnc)
*   [noVNC](https://github.com/novnc/noVNC)
*   [Cloudflare Tunnel](https://github.com/cloudflare/cloudflared)

## 📄 License
MIT License
