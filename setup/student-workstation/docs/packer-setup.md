# Workshop AI Desktop - Packer Provisioning Manual

## Project Overview

This Packer project sets up a workshop-ready Ubuntu 24.04 LTS environment with pre-installed development tools. It's designed for training sessions, workshops, and demo environments requiring a consistent, feature-rich desktop environment.

## What Gets Installed

### Software Components
- **Google Chrome** - Latest stable version
- **Visual Studio Code** - With TIBCO Flogo extension
- **Go Programming Language** - Latest version
- **RDP Server (xrdp)** - For remote desktop access via port 3389
- **XFCE Desktop Environment** - Lightweight desktop for RDP sessions
- **TIBCO Platform CLI** - Command-line tools for TIBCO platform
- **Basic Development Tools** - curl, wget, git, vim, nano, htop, zip/unzip

## Prerequisites

### Required Tools
1. **Packer** - Version 1.7+ required
2. **SSH Client** - For connecting to target VM
3. **Target Virtual Machine** - Running Ubuntu 24.04 LTS with SSH access

### Required Access
- SSH access to the target VM (either password or private key)
- Sudo privileges on the target VM
- Internet connectivity on the target VM

## Setup Instructions

### 1. Install Packer (if not already installed)

```bash
# Download and install Packer
wget https://releases.hashicorp.com/packer/1.15.0/packer_1.15.0_linux_amd64.zip
unzip packer_1.15.0_linux_amd64.zip
sudo mv packer /usr/local/bin/
rm packer_1.15.0_linux_amd64.zip

# Verify installation
packer version
```

### 2. Prepare Your Target VM

Ensure your target Ubuntu VM has:
- Ubuntu 24.04 LTS installed
- SSH server running (`sudo systemctl enable ssh --now`)
- User account with sudo privileges
- Internet connectivity for package downloads

### 3. Configure SSH Connection

Choose one of the authentication methods:

#### Option A: SSH Private Key Authentication (Recommended)
```bash
export SSH_HOST="your-vm-ip-or-hostname"
export SSH_USER="your-username"
export SSH_PRIVATE_KEY_PATH="/path/to/your/private/key"
export SSH_PORT="22"  # Optional, defaults to 22
```

#### Option B: SSH Password Authentication
```bash
export SSH_HOST="your-vm-ip-or-hostname"
export SSH_USER="your-username"
export SSH_PASSWORD="your-password"
export SSH_PORT="22"  # Optional, defaults to 22
```

### 4. Run the Provisioning

Execute the build script:

```bash
# Make the build script executable
chmod +x build-ssh.sh

# Run the full provisioning
./build-ssh.sh
```

## Manual Provisioning Steps

If you prefer to run Packer commands manually:

### 1. Set Environment Variables
```bash
export SSH_HOST="your-vm-ip-or-hostname"
export SSH_USER="your-username"
export SSH_PRIVATE_KEY_PATH="/path/to/your/private/key"  # OR SSH_PASSWORD
```

### 2. Initialize and Validate
```bash
# Make all scripts executable
chmod +x scripts/*.sh

# Initialize Packer
packer init azure-ubuntu-ssh.pkr.hcl

# Validate configuration
packer validate azure-ubuntu-ssh.pkr.hcl
```

### 3. Run the Build
```bash
# Execute the provisioning
packer build azure-ubuntu-ssh.pkr.hcl
```

## Post-Installation Access

### SSH Access
```bash
# Connect as your original user
ssh your-username@your-vm-ip
```

### RDP Access
1. **Address**: `your-vm-ip:3389`
2. **Username**: Your existing username
3. **Password**: Your existing password
4. **Desktop Environment**: XFCE4

### Testing the Installation

After provisioning, verify the installation:

```bash
# Check installed software versions
google-chrome --version
code --version
go version
sudo systemctl status xrdp

# List VS Code extensions
code --list-extensions
```

## Troubleshooting

### Common Issues

#### SSH Connection Fails
```bash
# Test SSH connection manually
ssh -o ConnectTimeout=10 your-username@your-vm-ip

# Check SSH service status on target VM
sudo systemctl status ssh
```

#### Permission Denied During Provisioning
- Ensure your user has sudo privileges
- Check if passwordless sudo is configured: `sudo visudo` and add `your-username ALL=(ALL) NOPASSWD:ALL`

#### RDP Connection Issues
```bash
# Check xrdp status
sudo systemctl status xrdp

# Restart xrdp if needed
sudo systemctl restart xrdp

# Check if port 3389 is open
sudo netstat -tlnp | grep 3389
```

#### VS Code Extension Installation Fails
- Verify the Flogo extension file exists in the `files/` directory
- Check file permissions and path in the Packer configuration

### Build Process Cleanup

If you need to re-run the provisioning:

```bash
# Most scripts check for existing installations and skip if already present
# To force reinstallation, you may need to manually remove installed software

# Remove Chrome
sudo apt-get remove --purge google-chrome-stable

# Remove VS Code
sudo apt-get remove --purge code
```

## Customization

### Modifying Installed Software

Edit the corresponding script files in the `scripts/` directory:
- [scripts/install-chrome.sh](scripts/install-chrome.sh) - Chrome installation
- [scripts/install-visualcode.sh](scripts/install-visualcode.sh) - VS Code and extensions
- [scripts/install-go.sh](scripts/install-go.sh) - Go language setup
- [scripts/install-rdp.sh](scripts/install-rdp.sh) - RDP server configuration

### Adding New Software

1. Create a new script in the `scripts/` directory
2. Make it executable: `chmod +x scripts/your-script.sh`
3. Add a provisioner block to [azure-ubuntu-ssh.pkr.hcl](azure-ubuntu-ssh.pkr.hcl):

```hcl
provisioner "shell" {
  script = "scripts/your-script.sh"
}
```

## File Structure

```
packer/
├── azure-ubuntu-ssh.pkr.hcl       # Main Packer configuration
├── build-ssh.sh                   # Automated build script
├── variables.pkrvars.hcl           # Variable definitions
├── ssh-manifest.json               # Build output manifest
├── files/
│   ├── flogo-vscode-linux-x64-2.26.0-1798.vsix
│   └── tibco-platform-cli_1.5.0-linux-amd64.zip
└── scripts/
    ├── cleanup.sh                  # Post-installation cleanup
    ├── install-basics.sh           # Basic tools installation
    ├── install-chrome.sh           # Google Chrome installation
    ├── install-go.sh              # Go language installation
    ├── install-rdp.sh             # RDP server setup
    ├── install-visualcode.sh      # VS Code installation
    └── update-system.sh           # System updates
```

## Security Considerations

⚠️ **Important Security Notes**:

1. **RDP Access**: RDP is exposed on port 3389 - ensure proper firewall rules
4. **SSH Keys**: Use SSH key authentication instead of passwords when possible

## Support and Maintenance

### Regular Updates
- Run system updates regularly: `sudo apt-get update && sudo apt-get upgrade`
- Update installed software packages as needed
- Monitor security advisories for installed components

### Backup Considerations
- Consider creating a VM snapshot after successful provisioning
- Document any custom configurations for future reference
- Backup SSH keys and access credentials securely

---

**Project Maintainers**: TIBCO Workshop Team  
**Last Updated**: February 2026  
**Packer Version**: 1.15.0+  
**Target OS**: Ubuntu 24.04 LTS