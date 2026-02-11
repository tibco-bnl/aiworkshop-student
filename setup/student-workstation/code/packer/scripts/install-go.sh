#!/bin/bash
set -e

# Check if Go is already installed
if [ -x "/usr/local/go/bin/go" ]; then
    echo "Go is already installed: $(/usr/local/go/bin/go version)"
    echo "Skipping Go installation..."
    exit 0
fi

echo "=== Installing Go 1.24.6 ==="

wget https://go.dev/dl/go1.24.6.linux-amd64.tar.gz

sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.24.6.linux-amd64.tar.gz
#rm go1.24.6.linux-amd64.tar.gz
        
# Add Go to PATH for all users
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/go.sh
sudo chmod +x /etc/profile.d/go.sh
source /etc/profile.d/go.sh


# Verify installation
go version

echo "=== Go installation completed ==="
echo "Go version: $(go version)"