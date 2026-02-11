packer {
  # Using null builder with SSH communicator
}

# Variables for SSH connection
variable "ssh_host" {
  type        = string
  description = "SSH host (IP address or hostname)"
  default     = env("SSH_HOST")
}

variable "ssh_user" {
  type        = string
  description = "SSH username"
  default     = env("SSH_USER")
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key file"
  default     = env("SSH_PRIVATE_KEY_PATH")
}

variable "ssh_password" {
  type        = string
  description = "SSH password (if not using key)"
  default     = env("SSH_PASSWORD")
  sensitive   = true
}

variable "ssh_port" {
  type        = number
  description = "SSH port"
  default     = 22
}

# Source configuration using null builder with SSH communicator
source "null" "ubuntu" {
  communicator = "ssh"
  ssh_host     = var.ssh_host
  ssh_username = var.ssh_user
  ssh_port     = var.ssh_port
  
  # Use either private key or password
  ssh_private_key_file = var.ssh_private_key_path != "" ? var.ssh_private_key_path : null
  ssh_password        = var.ssh_password != "" ? var.ssh_password : null
  
  # Connection settings
  ssh_timeout             = "10m"
  ssh_handshake_attempts  = 10
  ssh_keep_alive_interval = "5s"
}

# Build configuration
build {
  name = "ubuntu-chrome-ssh-build"
  sources = [
    "source.null.ubuntu"
  ]

  # Wait for system to be ready
  provisioner "shell" {
    inline = [
      "echo 'Waiting for system to be ready...'",
      "sudo cloud-init status --wait || true",
      "echo 'System ready for provisioning'"
    ]
  }

  # Update system
  provisioner "shell" {
    script = "scripts/update-system.sh"
  }

  # Install basic tools
  provisioner "shell" {
    script = "scripts/install-basics.sh"
  }

  # Install Google Chrome
  provisioner "shell" {
    script = "scripts/install-chrome.sh"
  }

  # Install RDP (Remote Desktop Protocol) support
  provisioner "shell" {
    script = "scripts/install-rdp.sh"
  }

  # Install Go
  provisioner "shell" {
    script = "scripts/install-go.sh"
  }

  # Copy Flogo VS Code extension
  provisioner "file" {
    source = "files/flogo-vscode-linux-x64-2.26.0-1798.vsix"
    destination = "/tmp/flogo-vscode-linux-x64-2.26.0-1798.vsix"
  }

  # Install Visual Studio Code (includes Flogo extension)
  provisioner "shell" {
    script = "scripts/install-visualcode.sh"
  }
  # install rdp extensions
    provisioner "shell" {
    script = "scripts/install-rdp.sh"
    }   

  # Cleanup
  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }

  # Output summary
  provisioner "shell" {
    inline = [
      "echo '=== Installation Summary ==='",
      "echo 'OS Version: '$(lsb_release -d)",
      "echo 'Chrome Version: '$(google-chrome --version)",
      "echo 'Go version: '$(go version || echo 'Go not installed')",
      "echo 'Visual Studio Code version: '$(code --version | head -1 || echo 'VS Code not installed')",
      "echo 'Installed VS Code Extensions:'",
      "code --list-extensions | grep -E '(flogo|golang|python|remote-ssh)' || echo 'Extensions not found'",
      "echo 'RDP Status: '$(sudo systemctl is-active xrdp || echo 'RDP not active')",
      "echo 'RDP Port: 3389'",
      "echo 'Desktop Environment: XFCE4'",
      "echo 'Installation completed successfully!'"
    ]
  }

  post-processor "manifest" {
    output = "ssh-manifest.json"
    strip_path = true
  }
}