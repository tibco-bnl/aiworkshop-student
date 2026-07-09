
#!/bin/bash

# Defaults
USER_NAME_PREFIX="user"
USER_NUMBER_START=1
USER_COUNT=1
USER_PASSWORD="Tibco2026"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--prefix)
            USER_NAME_PREFIX="$2"
            shift 2
            ;;
        -s|--start)
            USER_NUMBER_START="$2"
            shift 2
            ;;
        -c|--count)
            USER_COUNT="$2"
            shift 2
            ;;
        -P|--password)
            USER_PASSWORD="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -p, --prefix     User name prefix (default: user)"
            echo "  -s, --start      Starting number (default: 1)"
            echo "  -c, --count      Number of users (default: 1)"
            echo "  -P, --password   Password (default: Tibco2026)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

USER_NUMBER_END=$((USER_NUMBER_START+$USER_COUNT-1))

for i in $(seq $USER_NUMBER_START $USER_NUMBER_END); do
    USERNAME="${USER_NAME_PREFIX}$(printf "%02d" "$i")"
    echo "Creating user: $USERNAME"

    # Create user with home directory
    sudo useradd -m -s /bin/bash "$USERNAME"

    # Set password
    echo "$USERNAME:$USER_PASSWORD" | sudo chpasswd

    # Add user to useful groups
    sudo usermod -aG tibco,users "$USERNAME"

    # Create desktop directory for RDP access
    sudo -u "$USERNAME" mkdir -p /home/"$USERNAME"/Desktop
    sudo -u "$USERNAME" mkdir -p /home/"$USERNAME"/Documents
    sudo -u "$USERNAME" mkdir -p /home/"$USERNAME"/Downloads

    # Set proper ownership
    sudo chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"
    echo "User $USERNAME created successfully"
done
