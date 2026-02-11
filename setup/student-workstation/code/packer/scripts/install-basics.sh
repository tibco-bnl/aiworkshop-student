#!/bin/bash
set -e

# Check if basic tools are already installed
if command -v curl &> /dev/null && command -v git &> /dev/null && command -v vim &> /dev/null; then
    echo "Basic tools appear to be already installed:"
    echo "  curl: $(curl --version | head -1)"
    echo "  git: $(git --version)"
    echo "  vim: $(vim --version | head -1)"
    echo "Skipping basic tools installation..."
    exit 0
fi

echo "=== Installing basic tools and utilities ==="

# Install basic development and system tools
sudo apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    unzip \
    zip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential \
    net-tools \
    tree

# Install snap if not present
if ! command -v snap &> /dev/null; then
    sudo apt-get install -y snapd
fi

echo "=== Basic tools installation completed ==="