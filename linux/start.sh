#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$BASE_DIR/bin"
LIB_DIR="$BASE_DIR/lib"
PASS_FILE="$BASE_DIR/vnc.pass"

# Check x11vnc
if ! command -v x11vnc &> /dev/null; then
    echo "Error: x11vnc not found. Please run 'sudo apt install x11vnc'"
    exit 1
fi

echo "------------------------------------------------------------------"
echo "              ClickTop-Linux Remote Desktop Setup"
echo "------------------------------------------------------------------"

# Password Logic
if [ -f "$PASS_FILE" ]; then
    echo "🔑 Existing password file found."
    read -p "Do you want to define a NEW password? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$PASS_FILE"
    fi
fi

if [ ! -f "$PASS_FILE" ]; then
    echo "creating new password..."
    while true; do
        read -s -p "Enter VNC Password (max 8 chars): " PASS
        echo
        if [ -z "$PASS" ]; then
             echo "Password cannot be empty."
             continue
        fi
        
        read -s -p "Confirm Password: " PASS_CONFIRM
        echo
        
        if [ "$PASS" == "$PASS_CONFIRM" ]; then
            break
        else
            echo "❌ Passwords do not match. Try again."
        fi
    done
    
    x11vnc -storepasswd "$PASS" "$PASS_FILE"
    echo "✅ Password saved."
fi

# Kill existing processes
pkill -f "x11vnc -display :0" || true
pkill -f "novnc_proxy" || true
pkill -f "cloudflared tunnel" || true

# Start x11vnc
echo "🚀 Starting VNC Server..."
x11vnc -display :0 -rfbauth "$PASS_FILE" -forever -shared -bg -o "$BASE_DIR/x11vnc.log"

# Start noVNC
echo "🌐 Starting noVNC..."
"$LIB_DIR/noVNC/utils/novnc_proxy" --vnc localhost:5900 --listen 6080 > "$BASE_DIR/novnc.log" 2>&1 &
NOVNC_PID=$!

# Start Cloudflare Tunnel
echo "🚇 Starting Tunnel..."
"$BIN_DIR/cloudflared" tunnel --url http://localhost:6080 > "$BASE_DIR/tunnel.log" 2>&1 &
TUNNEL_PID=$!

echo "⏳ Services started. Waiting for tunnel URL..."
sleep 8
URL=$(grep -o 'https://.*\.trycloudflare\.com' "$BASE_DIR/tunnel.log" | head -n 1)

if [ -z "$URL" ]; then
    echo "⚠️ Tunnel URL not found yet. Check tunnel.log:"
    tail -n 5 "$BASE_DIR/tunnel.log"
else
    echo "=========================================="
    echo "ACCESS URL: $URL/vnc.html"
    echo "=========================================="
fi

# Wait for user to stop
wait $NOVNC_PID $TUNNEL_PID
