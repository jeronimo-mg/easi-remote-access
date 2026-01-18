#!/bin/bash
set -e

BASE_DIR="$(pwd)"
BIN_DIR="$BASE_DIR/bin"
LIB_DIR="$BASE_DIR/lib"

mkdir -p "$BIN_DIR"
mkdir -p "$LIB_DIR"

# 1. Download Cloudflared
if [ ! -f "$BIN_DIR/cloudflared" ]; then
    echo "Downloading Cloudflared..."
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o "$BIN_DIR/cloudflared"
    chmod +x "$BIN_DIR/cloudflared"
    echo "Cloudflared downloaded."
else
    echo "Cloudflared already exists."
fi

# 2. Download noVNC and Websockify
if [ ! -d "$LIB_DIR/noVNC" ]; then
    echo "Cloning noVNC..."
    git clone https://github.com/novnc/noVNC.git "$LIB_DIR/noVNC"
else
    echo "noVNC already exists."
fi

if [ ! -d "$LIB_DIR/noVNC/utils/websockify" ]; then
    echo "Cloning websockify..."
    git clone https://github.com/novnc/websockify "$LIB_DIR/noVNC/utils/websockify"
else
    echo "websockify already exists."
fi

echo "Setup complete. Checking for x11vnc..."
if ! command -v x11vnc &> /dev/null; then
    echo "WARNING: x11vnc is NOT installed. You must install it manually."
    echo "Run: sudo apt install x11vnc"
else
    echo "x11vnc is found."
fi
