#!/bin/bash
set -e

# Check if Visual Studio Code is already installed
if command -v code &> /dev/null; then
    echo "Visual Studio Code is already installed: $(code --version | head -1)"
    echo "Checking for Flogo extension..."
    
    # Still check and install Flogo extension if needed
    if [ -f "/tmp/flogo-vscode-linux-x64-2.26.0-1798.vsix" ]; then
        if ! code --list-extensions | grep -q "tibco.flogo"; then
            echo "Installing Flogo VS Code extension..."
            code --install-extension /tmp/flogo-vscode-linux-x64-2.26.0-1798.vsix --force
            echo "Flogo extension installed successfully"
        else
            echo "Flogo extension is already installed"
        fi
    fi
    
    echo "Skipping VS Code installation..."
    exit 0
fi

echo "=== Installing Visual Studio Code ==="

# Add Microsoft's signing key
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/packages.microsoft.gpg
rm packages.microsoft.gpg   

# Add Visual Studio Code repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

# Update package lists to include Visual Studio Code repository
sudo apt-get update

# Install Visual Studio Code
sudo apt-get install -y code

# Install useful VS Code extensions
code --install-extension ms-vscode-remote.remote-ssh --force
code --install-extension golang.Go --force
code --install-extension ms-python.python --force

# Install Flogo VS Code extension if it exists
if [ -f "/tmp/flogo-vscode-linux-x64-2.26.0-1798.vsix" ]; then
    echo "Installing Flogo VS Code extension..."
    code --install-extension /tmp/flogo-vscode-linux-x64-2.26.0-1798.vsix --force
    echo "Flogo extension installed successfully"
else
    echo "Flogo extension file not found, skipping..."
fi
            
# Verify installation
code --version

echo "=== Visual Studio Code installation completed ==="
echo "Visual Studio Code version: $(code --version | head -1)"
echo "Installed extensions:"
code --list-extensions