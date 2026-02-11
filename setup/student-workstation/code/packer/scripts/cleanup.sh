#!/bin/bash
set -e

echo "=== Starting system cleanup ==="

# Clean apt cache
sudo apt-get autoremove -y
sudo apt-get autoclean
sudo apt-get clean

# Clean temporary files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Clear bash history
history -c
cat /dev/null > ~/.bash_history

# Clear system logs (optional - comment out if you need logs for debugging)
sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;

# Clear user cache
rm -rf ~/.cache/*

# Remove unnecessary packages
sudo apt-get autoremove --purge -y

# Clear package cache
sudo apt-get clean

echo "=== System cleanup completed ==="