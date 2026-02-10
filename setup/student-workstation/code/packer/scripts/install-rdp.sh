#!/bin/bash
set -e

# Check if xrdp is already installed and running
if systemctl is-active --quiet xrdp 2>/dev/null; then
    echo "RDP (xrdp) is already installed and running"
    echo "RDP server status: $(systemctl is-active xrdp)"
    echo "Skipping RDP installation..."
    exit 0
fi

echo "=== Installing RDP (Remote Desktop Protocol) support ==="

# Update package lists first
sudo apt-get update

# Install xrdp (RDP server for Linux)
sudo apt-get install -y xrdp

# Install desktop environment (XFCE - lightweight)
sudo apt-get install -y xfce4 xfce4-goodies

# Configure xrdp to use XFCE
echo "xfce4-session" > ~/.xsession

# Configure xrdp for all users
sudo tee /etc/xrdp/startwm.sh > /dev/null <<EOF
#!/bin/sh
if [ -r /etc/default/locale ]; then
  . /etc/default/locale
  export LANG LANGUAGE
fi

# Start XFCE session
startxfce4
EOF

# Make the script executable
sudo chmod +x /etc/xrdp/startwm.sh

# Enable and start xrdp service
sudo systemctl enable xrdp
sudo systemctl start xrdp

# Configure firewall to allow RDP (port 3389)
sudo ufw allow 3389/tcp || echo "UFW not available or already configured"

# Add current user to ssl-cert group (required for xrdp)
sudo usermod -a -G ssl-cert $USER

# Configure xrdp to allow connections
sudo sed -i 's/^new_cursors=true/new_cursors=false/' /etc/xrdp/xrdp.ini || true

# Restart xrdp to apply configuration
sudo systemctl restart xrdp

# Check xrdp status
sudo systemctl status xrdp --no-pager

echo "=== RDP installation completed ==="
echo "RDP server is running on port 3389"
echo "You can now connect using any RDP client:"
echo "  - Address: $(hostname -I | awk '{print $1}'):3389"
echo "  - Username: Your current username"
echo "  - Password: Your user password"
echo ""
echo "Desktop environment: XFCE4"
echo "Note: Make sure port 3389 is open in your firewall/security groups"