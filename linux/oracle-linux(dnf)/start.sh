#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$BASE_DIR/bin"
LIB_DIR="$BASE_DIR/lib"
PASS_FILE="$BASE_DIR/vnc.pass"
DISPLAY_NUM=":1"
VNC_PORT="5901"

# Check TigerVNC
if ! rpm -q tigervnc-server &> /dev/null; then
    echo "Error: tigervnc-server not found. Please run 'sudo dnf install tigervnc-server'"
    exit 1
fi

echo "------------------------------------------------------------------"
echo "              ClickTop-Linux (Oracle/RHEL) Setup"
echo "------------------------------------------------------------------"

# Password Logic
if [ ! -f "$PASS_FILE" ]; then
    echo "Creating VNC password..."
    mkdir -p ~/.vnc
    while true; do
        read -s -p "Enter VNC Password (max 8 chars): " PASS
        echo
        if [ -z "$PASS" ]; then echo "Password cannot be empty."; continue; fi
        read -s -p "Confirm Password: " PASS_CONFIRM
        echo
        if [ "$PASS" == "$PASS_CONFIRM" ]; then break; else echo "❌ Passwords do not match."; fi
    done
    # Initialize vncpasswd
    echo "$PASS" | vncpasswd -f > ~/.vnc/passwd
    chmod 600 ~/.vnc/passwd
    echo "✅ Password saved to ~/.vnc/passwd"
fi

# Kill existing processes
echo "Cleaning up..."
pkill -f "Xvnc $DISPLAY_NUM" || true
pkill -f "novnc_proxy" || true
pkill -f "cloudflared tunnel" || true
rm -rf /tmp/.X11-unix/X${DISPLAY_NUM/:/}

# Start TigerVNC (Virtual Session)
echo "🚀 Starting VNC Server on $DISPLAY_NUM..."
# We use vncserver to launch a session. 
# Note: First run might prompt for creating startup script (~/.vnc/xstartup).
vncserver $DISPLAY_NUM -geometry 1280x720 -depth 24
# Wait for startup
sleep 3

# Start noVNC
echo "🌐 Starting noVNC..."
"$LIB_DIR/noVNC/utils/novnc_proxy" --vnc localhost:$VNC_PORT --listen 6080 > "$BASE_DIR/novnc.log" 2>&1 &
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
