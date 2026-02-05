#!/bin/bash

# setup_lite.sh - Install dependencies for Lightweight Remote Access (Xpra)

echo "Installing Xpra and dependencies..."

# Get Xpra repository
# Xpra is often not in default repos or is outdated. We use the official repo.
sudo apt-get update
sudo apt-get install -y wget gnupg

# Add Xpra GPG key and Repo
wget -q https://xpra.org/gpg.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb https://xpra.org/ $(lsb_release -cs) main"

sudo apt-get update
sudo apt-get install -y xpra xterm

echo "Installation complete."
echo "You can now run ./start_lite.sh"
