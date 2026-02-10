#!/bin/bash
set -e

echo "=== Updating system packages ==="

# Update package lists
sudo apt-get update

# Upgrade existing packages
sudo apt-get upgrade -y

# Install security updates
sudo unattended-upgrades

echo "=== System update completed ==="