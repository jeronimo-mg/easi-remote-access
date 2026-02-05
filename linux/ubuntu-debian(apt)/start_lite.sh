#!/bin/bash

# start_lite.sh - Starts Xpra (HTML5) + Cloudflare Tunnel
# This mode uses significantly less RAM/CPU than the full VNC desktop.

# Configuration
XPRA_PORT=10000
TUNNEL_LOG="tunnel_lite.log"

# Check if Xpra is installed
if ! command -v xpra &> /dev/null; then
    echo "Xpra not found. Please run ./setup_lite.sh first."
    exit 1
fi

echo "Cleaning up previous sessions..."
xpra stop :100 > /dev/null 2>&1
pkill -f "cloudflared.*$XPRA_PORT"

echo "Starting Xpra Server (Display :100)..."
# Start Xpra with HTML5 enabled, binding to localhost
# start-child=xterm ensures we have a terminal immediately
xpra start :100 --bind-tcp=127.0.0.1:$XPRA_PORT --html=on --start-child=xterm --daemon=yes --exit-with-children=yes

echo "Xpra started on port $XPRA_PORT."

# Resolve Paths
BASE_DIR="$(pwd)"
BIN_DIR="$BASE_DIR/bin"
CLOUDFLARED="cloudflared"

if [ -f "$BIN_DIR/cloudflared" ]; then
    CLOUDFLARED="$BIN_DIR/cloudflared"
fi

# Check for Cloudflared
if ! command -v $CLOUDFLARED &> /dev/null; then
    if [ "$CLOUDFLARED" == "cloudflared" ]; then
         echo "Error: cloudflared not found in PATH or ./bin."
         echo "Please run ./setup_tools.sh to install it."
         exit 1
    fi
fi

echo "Starting Cloudflare Tunnel..."
rm -f $TUNNEL_LOG
touch $TUNNEL_LOG

# Check for Token
if [ -f "tunnel_token.txt" ]; then
    echo "Using Fixed Tunnel (Token)..."
    $CLOUDFLARED tunnel run --token $(cat tunnel_token.txt) > $TUNNEL_LOG 2>&1 &
else
    echo "Using Quick Tunnel (Random URL)..."
    # We remove > /dev/null so we might see immediate errors if any, but --logfile handles the main output
    $CLOUDFLARED tunnel --url http://127.0.0.1:$XPRA_PORT --logfile $TUNNEL_LOG > /dev/null 2>&1 &
fi

echo "Waiting for URL..."
MAX_RETRIES=30
URL=""
for i in $(seq 1 $MAX_RETRIES); do
    sleep 2
    if grep -q "https://.*trycloudflare.com" $TUNNEL_LOG; then
        URL=$(grep -o "https://.*trycloudflare.com" $TUNNEL_LOG | head -n 1)
        break
    fi
done

if [ -n "$URL" ]; then
    echo "URL Found: $URL"
    # Send Email Notification
    if [ -f "send_email.py" ]; then
        echo "Sending email notification..."
        python3 send_email.py "$URL" &
    fi
else
    echo "Error: URL not found in $TUNNEL_LOG after waiting."
fi

echo ""
echo "Mode: LIGHTWEIGHT (Xpra)"
echo "1. Open the URL in your browser."
echo "2. You will see a Terminal window."
echo "3. To run an App, type: firefox &"
echo "4. To preserve resources, close the app when done."
echo ""
echo "Press Ctrl+C to stop."

# Keep alive
tail -f $TUNNEL_LOG
