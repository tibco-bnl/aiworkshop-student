#!/bin/bash
set -e

# Check if Node.js is already installed system-wide
if [ -x "/usr/local/bin/node" ]; then
    echo "Node.js is already installed: $(/usr/local/bin/node -v)"
    echo "Skipping Node.js installation..."
    exit 0
fi

echo "=== Installing Node.js via nvm ==="

# Download and install nvm
echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js
echo "Installing Node.js version 24..."
nvm install 24

# Verify the Node.js version from nvm
echo "Verifying Node.js installation from nvm..."
node -v # Should print "v24.14.1".

# Get the Node.js version that was installed
NODE_VERSION=$(node -v)
echo "Installed Node.js version: $NODE_VERSION"

# Copy Node.js binaries to system-wide location
echo "Making Node.js available system-wide..."
sudo mkdir -p /usr/local/nodejs
sudo cp -r "$HOME/.nvm/versions/node/$NODE_VERSION"/* /usr/local/nodejs/

# Create symlinks in /usr/local/bin for system-wide access
sudo ln -sf /usr/local/nodejs/bin/node /usr/local/bin/node
sudo ln -sf /usr/local/nodejs/bin/npm /usr/local/bin/npm
sudo ln -sf /usr/local/nodejs/bin/npx /usr/local/bin/npx

# Add Node.js to PATH for all users
echo 'export PATH=$PATH:/usr/local/nodejs/bin' | sudo tee /etc/profile.d/nodejs.sh
sudo chmod +x /etc/profile.d/nodejs.sh

# Verify system-wide installation
echo "Verifying system-wide Node.js installation..."
/usr/local/bin/node -v
/usr/local/bin/npm -v

echo "=== Node.js installation completed ==="
echo "Node.js version: $(/usr/local/bin/node -v)"
echo "npm version: $(/usr/local/bin/npm -v)"
echo "Node.js is now available system-wide for all users"