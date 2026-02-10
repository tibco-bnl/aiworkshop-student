#!/bin/bash
set -e

# Check if Google Chrome is already installed
if command -v google-chrome &> /dev/null; then
    echo "Google Chrome is already installed: $(google-chrome --version)"
    echo "Skipping Chrome installation..."
    exit 0
fi

echo "=== Installing Google Chrome ==="

# Add Google's signing key
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# Add Google Chrome repository
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

# Update package lists to include Chrome repository
sudo apt-get update

# Install Google Chrome stable
sudo apt-get install -y google-chrome-stable

# Verify installation
google-chrome --version

echo "=== Google Chrome installation completed ==="
echo "Chrome version: $(google-chrome --version)"