#!/bin/bash
set -e

echo "=== Creating demo users ==="

# Check if demo users already exist
if id "demouser-01" &>/dev/null; then
    echo "Demo users appear to already exist"
    echo "Existing demo users:"
    for i in $(seq -w 1 12); do
        if id "demouser-$i" &>/dev/null; then
            echo "  demouser-$i"
        fi
    done
    echo "Skipping user creation..."
    exit 0
fi

# Password for all demo users
DEMO_PASSWORD="Tibco@Demo2026"

echo "Creating 12 demo users with pattern 'demouser-XX'..."

# Create 12 users with sequence numbers (01-12)
for i in $(seq -w 1 12); do
    USERNAME="demouser-$i"
    
    echo "Creating user: $USERNAME"
    
    # Create user with home directory
    sudo useradd -m -s /bin/bash "$USERNAME"
    
    # Set password
    echo "$USERNAME:$DEMO_PASSWORD" | sudo chpasswd
    
    # Add user to useful groups
    sudo usermod -aG sudo,adm,cdrom,dip,plugdev,users "$USERNAME"
    
    # Create desktop directory for RDP access
    sudo -u "$USERNAME" mkdir -p /home/"$USERNAME"/Desktop
    sudo -u "$USERNAME" mkdir -p /home/"$USERNAME"/Documents
    sudo -u "$USERNAME" mkdir -p /home/"$USERNAME"/Downloads
    
    # Set proper ownership
    sudo chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"
    
    echo "User $USERNAME created successfully"
done

echo ""
echo "=== Demo users creation completed ==="
echo "Created users: demouser-01 through demouser-12"
echo "Password for all users: $DEMO_PASSWORD"
echo "All users have been added to sudo group"
echo ""
echo "Users can now:"
echo "  - SSH into the system"
echo "  - Connect via RDP on port 3389"
echo "  - Use sudo privileges"
echo ""
echo "Example RDP connection:"
echo "  Address: $(hostname -I | awk '{print $1}'):3389"
echo "  Username: demouser-01 (or demouser-02, etc.)"
echo "  Password: $DEMO_PASSWORD"