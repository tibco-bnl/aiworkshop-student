#!/bin/bash

# SSH-based Packer Build Script
# This script provisions software on an existing VM via SSH

set -e

echo "=== Ubuntu Chrome Installation via SSH ==="

# Check if required tools are installed
check_tool() {
    if ! command -v $1 &> /dev/null; then
        echo "Error: $1 is not installed. Please install it first."
        exit 1
    fi
}

echo "Checking required tools..."
check_tool "packer"

# Check for required SSH connection parameters
if [ -z "$SSH_HOST" ]; then
    echo "Error: SSH_HOST environment variable is not set."
    echo "Please set: export SSH_HOST='your-vm-ip-or-hostname'"
    exit 1
fi

if [ -z "$SSH_USER" ]; then
    echo "Error: SSH_USER environment variable is not set."
    echo "Please set: export SSH_USER='your-username'"
    exit 1
fi

if [ -z "$SSH_PRIVATE_KEY_PATH" ] && [ -z "$SSH_PASSWORD" ]; then
    echo "Error: Neither SSH_PRIVATE_KEY_PATH nor SSH_PASSWORD is set."
    echo "Please set one of:"
    echo "  export SSH_PRIVATE_KEY_PATH='/path/to/your/private/key'"
    echo "  export SSH_PASSWORD='your-password'"
    exit 1
fi

# Display connection info
echo "SSH Connection Details:"
echo "  Host: $SSH_HOST"
echo "  User: $SSH_USER"
echo "  Port: ${SSH_PORT:-22}"
if [ -n "$SSH_PRIVATE_KEY_PATH" ]; then
    echo "  Auth: Private key ($SSH_PRIVATE_KEY_PATH)"
else
    echo "  Auth: Password"
fi

# Test SSH connection
echo ""
echo "Testing SSH connection..."
if [ -n "$SSH_PRIVATE_KEY_PATH" ]; then
    if ssh -i "$SSH_PRIVATE_KEY_PATH" -o ConnectTimeout=10 -o BatchMode=yes "$SSH_USER@$SSH_HOST" "echo 'SSH connection successful'"; then
        echo "SSH connection test passed!"
    else
        echo "Error: SSH connection test failed!"
        exit 1
    fi
else
    echo "Please manually verify SSH connection works:"
    echo "  ssh $SSH_USER@$SSH_HOST"
    read -p "Press Enter to continue once you've verified SSH access..."
fi

# Make scripts executable
echo "Setting script permissions..."
chmod +x scripts/*.sh

# Initialize Packer
echo "Initializing Packer..."
packer init azure-ubuntu-ssh.pkr.hcl

# Validate configuration
echo "Validating Packer configuration..."
packer validate azure-ubuntu-ssh.pkr.hcl

# Run the provisioning
echo ""
echo "Starting provisioning..."
echo "This will install updates, basic tools, and Google Chrome on the target VM..."
echo ""

if packer build azure-ubuntu-ssh.pkr.hcl; then
    echo ""
    echo "=== Provisioning completed successfully! ==="
    echo ""
    echo "Google Chrome and other software have been installed on the VM."
    echo "Check the 'ssh-manifest.json' file for build details."
    echo ""
    echo "You can now connect to your VM and use Chrome:"
    echo "  ssh $SSH_USER@$SSH_HOST"
    echo "  google-chrome --version"
else
    echo ""
    echo "=== Provisioning failed! ==="
    echo "Check the output above for error details."
    exit 1
fi