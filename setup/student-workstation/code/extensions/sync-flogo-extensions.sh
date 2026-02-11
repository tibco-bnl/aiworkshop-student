#!/bin/bash

# Script to sync git repositories to vscode/extensions/flogo-extensions
# This script is idempotent - safe to run multiple times:
# 1. Pulls latest changes from git repositories (only if needed)
# 2. Creates a timestamped backup only if changes are detected
# 3. Copies directories from git to vscode/extensions/flogo-extensions (excluding .git folders)
#
# Usage: sync-flogo-extensions.sh [--force]
#   --force  : Force sync and backup even if no changes detected

set -e  # Exit on error

# Parse command line arguments
FORCE_SYNC=false
if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
    FORCE_SYNC=true
fi

# Define base directories
WORKSHOP_DIR="/workshop"
GIT_DIR="$WORKSHOP_DIR/git"
TARGET_DIR="$WORKSHOP_DIR/vscode/extensions/flogo-extensions"
BACKUP_DIR="$WORKSHOP_DIR/backups"

# Create timestamp for backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/flogo-extensions_backup_$TIMESTAMP.tgz"

# Flags to track if any changes occurred
GIT_CHANGES=false
SYNC_NEEDED=false

echo "================================================"
echo "Flogo Extensions Sync Script "
echo "================================================"
echo "Source: $GIT_DIR"
echo "Target: $TARGET_DIR"
if [ "$FORCE_SYNC" = true ]; then
    echo "Mode: FORCED SYNC"
fi
echo ""

# Step 1: Pull all git repositories
echo "Step 1: Checking and pulling git repositories..."
echo "------------------------------------------------"

pull_repo() {
    local repo_path="$1"
    local repo_name="$2"
    
    cd "$repo_path"
    
    # Fetch to check for updates
    git fetch > /dev/null 2>&1 || { echo "Warning: Failed to fetch $repo_name"; return 1; }
    
    # Check if there are any updates
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "$LOCAL")
    
    if [ "$LOCAL" = "$REMOTE" ]; then
        echo "  $repo_name: Already up-to-date"
    else
        echo "  $repo_name: Pulling changes..."
        git pull || { echo "Warning: Failed to pull $repo_name"; return 1; }
        GIT_CHANGES=true
    fi
    
    cd - > /dev/null
    return 0
}

for dir in "$GIT_DIR"/*; do
    if [ -d "$dir/.git" ]; then
        pull_repo "$dir" "$(basename "$dir")"
    fi
done

# Also check subdirectories (like git/extensions/*)
if [ -d "$GIT_DIR/extensions" ]; then
    for dir in "$GIT_DIR/extensions"/*; do
        if [ -d "$dir/.git" ]; then
            pull_repo "$dir" "extensions/$(basename "$dir")"
        fi
    done
fi

echo ""

# Step 2: Check if sync is needed
echo "Step 2: Checking if sync is needed..."
echo "------------------------------------------------"

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Use rsync dry-run with itemize-changes to check if there are any differences
for source_dir in "$GIT_DIR"/*; do
    if [ -d "$source_dir" ]; then
        dir_name=$(basename "$source_dir")
        
        # Run rsync in dry-run mode with itemize-changes flag
        # This will only output lines starting with characters like <f, >f, cd, *deleting if there are actual changes
        RSYNC_CHECK=$(rsync -ain --delete --exclude='.git' --exclude='.gitignore' "$source_dir/" "$TARGET_DIR/$dir_name/" 2>/dev/null)
        
        if [ -n "$RSYNC_CHECK" ]; then
            SYNC_NEEDED=true
            echo "  Changes detected in: $dir_name"
        else
            echo "  $dir_name: Already in sync"
        fi
    fi
done

if [ "$SYNC_NEEDED" = false ] && [ "$FORCE_SYNC" = false ]; then
    echo "  No changes detected - target is already in sync"
    echo ""
    echo "================================================"
    echo "Sync Status: Up-to-date"
    echo "================================================"
    if [ "$GIT_CHANGES" = true ]; then
        echo "Note: Git repositories were updated but no file changes detected"
    else
        echo "No git updates or file changes needed"
    fi
    echo ""
    echo "To force sync anyway, run with --force flag"
    echo "================================================"
    exit 0
fi

if [ "$FORCE_SYNC" = true ] && [ "$SYNC_NEEDED" = false ]; then
    echo "  No changes detected, but FORCE mode enabled - proceeding anyway"
elif [ "$SYNC_NEEDED" = true ]; then
    echo "  Sync required - proceeding with backup and copy"
fi
echo ""

# Step 3: Create backup only if sync is needed or forced
echo "Step 3: Creating backup..."
echo "------------------------------------------------"

mkdir -p "$BACKUP_DIR"

# Create backup of target directory if it exists and has content
if [ -d "$TARGET_DIR" ] && [ "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]; then
    echo "Backing up $TARGET_DIR to $BACKUP_FILE"
    tar -czf "$BACKUP_FILE" -C "$(dirname "$TARGET_DIR")" "$(basename "$TARGET_DIR")"
    echo "Backup created: $BACKUP_FILE"
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "Backup size: $BACKUP_SIZE"
else
    echo "Target directory is empty or doesn't exist, skipping backup"
    BACKUP_FILE="(none - no backup needed)"
fi

echo ""

# Step 4: Copy directories from git to vscode/extensions/flogo-extensions
echo "Step 4: Syncing directories..."
echo "------------------------------------------------"

# Copy each directory from git, excluding .git folders
for source_dir in "$GIT_DIR"/*; do
    if [ -d "$source_dir" ]; then
        dir_name=$(basename "$source_dir")
        echo "Syncing: $dir_name"
        
        # Use rsync to copy, excluding .git directories
        rsync -av --delete --exclude='.git' --exclude='.gitignore' "$source_dir/" "$TARGET_DIR/$dir_name/"
    fi
done

echo ""
echo "================================================"
echo "Sync complete!"
echo "================================================"
echo "Summary:"
[ "$GIT_CHANGES" = true ] && echo "- Git repositories updated" || echo "- Git repositories already up-to-date"
if [ "$FORCE_SYNC" = true ] && [ "$SYNC_NEEDED" = false ]; then
    echo "- Force mode: Sync performed despite no changes detected"
fi
echo "- Backup saved to: $BACKUP_FILE"
echo "- Directories synced to: $TARGET_DIR"
echo ""
if [ "$BACKUP_FILE" != "(none - no backup needed)" ]; then
    echo "To restore from backup, run:"
    echo "  tar -xzf $BACKUP_FILE -C $WORKSHOP_DIR/vscode/extensions/"
fi
echo "================================================"
