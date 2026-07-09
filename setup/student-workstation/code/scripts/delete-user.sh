#!/bin/bash

# Defaults
USER_NAME_PREFIX="user"
USER_NUMBER_START=1
USER_COUNT=1

print_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -p, --prefix     User name prefix (default: user)"
    echo "  -s, --start      Starting number (default: 1)"
    echo "  -c, --count      Number of users (default: 1)"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -p participant -s 1 -c 6"
    echo "  Deletes users participant01 through participant06"
}

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
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

USER_NUMBER_END=$((USER_NUMBER_START + USER_COUNT - 1))

for i in $(seq "$USER_NUMBER_START" "$USER_NUMBER_END"); do
    USERNAME="${USER_NAME_PREFIX}$(printf "%02d" "$i")"
    echo "Deleting user: $USERNAME"

    if id "$USERNAME" >/dev/null 2>&1; then
        sudo userdel -r "$USERNAME"
        if [[ $? -eq 0 ]]; then
            echo "User $USERNAME deleted successfully"
        else
            echo "Failed to delete user $USERNAME"
        fi
    else
        echo "User $USERNAME does not exist, skipping"
    fi
done
