# Ubuntu 24 with Chrome - Azure Packer Build

This Packer project creates a custom Azure VM image based on Ubuntu 24.04 LTS with Google Chrome pre-installed.

## Prerequisites

1. **Azure CLI**: Install and configure Azure CLI
2. **Packer**: Install Packer (version 1.7+)
3. **Azure Service Principal**: Create a service principal for Packer authentication

## Setup Instructions

### 1. Install Required Tools

```bash
# Install Azure CLI (if not already installed)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Packer (if not already installed)
wget https://releases.hashicorp.com/packer/1.15.0/packer_1.15.0_linux_amd64.zip
unzip packer_1.15.0_linux_amd64.zip
sudo mv packer /usr/local/bin/
rm packer_1.15.0_linux_amd64.zip
```

### 2. Choose Your Build Method

#### Option A: Azure ARM Builder (Creates new VM from base image)

**Azure CLI Authentication (Recommended for development)**
```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "your-subscription-id"

# Create a resource group for Packer images
az group create --name rg-packer-images --location "East US"
```

**Service Principal Authentication (Recommended for CI/CD)**
```bash
# Create a service principal
az ad sp create-for-rbac --name "packer-sp" --role Contributor --scopes /subscriptions/YOUR_SUBSCRIPTION_ID

# Set environment variables
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="your-tenant-id"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
```

#### Option B: SSH-Based Provisioning (Use existing VM)

If you already have SSH access to a VM, you can use the SSH approach:

```bash
# Set SSH connection details
export SSH_HOST="20.67.24.154"
export SSH_USER="tibco"
#export SSH_PRIVATE_KEY_PATH="/path/to/your/private/key"
# or
export SSH_PASSWORD="Tibco@123456"  # if using password authentication
```

**Note**: SSH method provisions an existing VM but doesn't create a reusable Azure image. For image creation, you'll still need Azure credentials.

### 3. Customize Variables

Edit `variables.pkrvars.hcl` or set environment variables:

```bash
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="your-tenant-id"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
```

## Building the Image

### Method A: Azure ARM Builder

#### 1. Initialize Packer
```bash
packer init azure-ubuntu.pkr.hcl
```

#### 2. Validate the Configuration
```bash
packer validate -var-file="variables.pkrvars.hcl" azure-ubuntu.pkr.hcl
```

#### 3. Build the Image
```bash
packer build -var-file="variables.pkrvars.hcl" azure-ubuntu.pkr.hcl
```

### Method B: SSH-Based Provisioning

#### 1. SSH configuration is ready
The `azure-ubuntu-ssh.pkr.hcl` configuration uses built-in SSH functionality (no plugins needed).

#### 2. Validate the configuration
```bash
packer validate azure-ubuntu-ssh.pkr.hcl
```

#### 3. Provision existing VM
```bash
packer build azure-ubuntu-ssh.pkr.hcl
```

### 4. Build with Custom Variables (Optional)
```bash
packer build \
  -var 'image_name=my-custom-ubuntu' \
  -var 'image_version=2.0.0' \
  -var 'vm_size=Standard_B4ms' \
  -var-file="variables.pkrvars.hcl" \
  azure-ubuntu.pkr.hcl
```

## Project Structure

```
.
├── azure-ubuntu.pkr.hcl     # Main Packer config (Azure ARM)
├── azure-ubuntu-ssh.pkr.hcl # SSH-based Packer config
├── variables.pkrvars.hcl    # Variables file (for Azure ARM)
├── build.sh                 # Azure ARM build script
├── build-ssh.sh             # SSH-based build script
├── scripts/                 # Installation scripts
│   ├── update-system.sh     # System updates
│   ├── install-basics.sh    # Basic tools installation
│   ├── install-chrome.sh    # Google Chrome installation
│   └── cleanup.sh           # System cleanup
├── README.md                # This file
├── manifest.json            # Azure build output
└── ssh-manifest.json        # SSH build output
```

## Customization

### SSH Connection Examples

**Using SSH private key:**
```bash
export SSH_HOST="192.168.1.100"
export SSH_USER="ubuntu"
export SSH_PRIVATE_KEY_PATH="~/.ssh/id_rsa"
./build-ssh.sh
```

**Using SSH password:**
```bash
export SSH_HOST="my-vm.example.com"
export SSH_USER="azureuser"
export SSH_PASSWORD="your-password"
./build-ssh.sh
```

**Using custom SSH port:**
```bash
export SSH_HOST="192.168.1.100"
export SSH_USER="ubuntu"
export SSH_PORT="2222"
export SSH_PRIVATE_KEY_PATH="~/.ssh/id_rsa"
packer build azure-ubuntu-ssh.pkr.hcl
```

### Adding More Software

1. Create new installation scripts in the `scripts/` directory
2. Add them to the build section in `azure-ubuntu.pkr.hcl`

Example:
```hcl
provisioner "shell" {
  script = "scripts/install-docker.sh"
}
```

### Modifying VM Size

Change the `vm_size` variable in `variables.pkrvars.hcl` or use the `-var` flag:
```bash
packer build -var 'vm_size=Standard_D2s_v3' -var-file="variables.pkrvars.hcl" azure-ubuntu.pkr.hcl
```

### Changing Base OS

Modify the image configuration in the source block of `azure-ubuntu.pkr.hcl`:
```hcl
image_publisher = "Canonical"
image_offer     = "0001-com-ubuntu-server-noble"
image_sku       = "24_04-lts-gen2"
```

## Troubleshooting

### Common Issues

1. **Authentication Failed**: Ensure Azure credentials are properly set
2. **Resource Group Not Found**: Create the resource group before building
3. **Permission Denied**: Ensure the service principal has Contributor access

### Debugging

Enable debug logging:
```bash
export PACKER_LOG=1
packer build -var-file="variables.pkrvars.hcl" azure-ubuntu.pkr.hcl
```

### Script Permissions

All scripts in the `scripts/` directory should be executable:
```bash
chmod +x scripts/*.sh
```

## Using the Built Image

After successful build, you can create VMs from the custom image:

```bash
az vm create \
  --resource-group "your-resource-group" \
  --name "my-vm" \
  --image "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/rg-packer-images/providers/Microsoft.Compute/images/ubuntu-24-chrome-1.0.0" \
  --admin-username "azureuser" \
  --generate-ssh-keys
```

## Cost Optimization

- Use appropriate VM sizes during build
- Clean up temporary resources after build
- Consider using spot instances for cost savings
- Delete unused images to reduce storage costs

## Security Considerations

- Keep the base image updated
- Review and audit installation scripts
- Use managed identities when possible
- Regularly rebuild images with security updates