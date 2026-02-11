 # Standardized User Setup for an Ubuntu RDP VM

This document describes the **recommended approach** for creating multiple users on an Ubuntu VM accessed via **RDP (xrdp)**, ensuring all users receive the same baseline desktop experience while maintaining clean, isolated home directories.

This approach is suitable for small RDS-style environments (e.g., ~6 users).

---

## Goals

* Consistent desktop experience for all users
* Separate home directories and sessions
* Easy user creation and future scaling
* Avoid copying broken or session-specific files

---

## Overview of the Approach

1. Configure one **template user** interactively
2. Populate `/etc/skel` with safe user-level defaults
3. Set **system-wide GNOME (dconf) defaults**
4. Create users normally with `adduser`
5. Validate xrdp session behavior
6. (Optional) Lock down critical desktop settings


## Step 0: No changes required to Template User
In case there are no change required to the Template use progress to  [step 4](#step-4-create-user-accounts) to create the new user accounts.


---

## Step 1: Prepare a Template User

Log in via RDP as the user you want to use as the baseline.

Ensure the following are finalized:

* Desktop layout and theme
* GNOME extensions required for RDP
* Terminal, editor, and app preferences
* No personal accounts logged in (email, browser sync, SSO)

This user will **not** be reused directly — it is only a source of defaults.
The user used for this is named demouser-01.

---

## Step 2: Populate `/etc/skel`

`/etc/skel` is copied automatically when new users are created.

Copy only safe, reusable configuration files from the template user.

### Recommended Command

```bash
sudo rsync -a \
  --exclude={.cache,.ssh,.pcsc*,.dbus,.gvfs,Downloads,Videos} \
  /home/demouser-01/ \
  /etc/skel/
```

Fix ownership:

```bash
sudo chown -R root:root /etc/skel
```

### Important Rules for `/etc/skel`

* Must contain **only** regular files, directories, and symlinks
* Must not include runtime, cache, socket, or credential files

---

## Step 3: Capture and Apply GNOME Desktop Defaults (dconf)

Most GNOME desktop settings are stored in **dconf**, not dotfiles.

### Export Settings from the Template User

```bash
dconf dump / > /tmp/desktop-defaults.dconf
```

### Create System-Wide Defaults

```bash
sudo mkdir -p /etc/dconf/db/local.d
sudo nano /etc/dconf/db/local.d/00-defaults
```

Paste the contents of `desktop-defaults.dconf` into this file.

Apply the configuration:

```bash
sudo dconf update
```

Result:

* All **new users** inherit these desktop defaults
* Users can still customize their own sessions unless settings are locked

---

## Step 4: Create User Accounts

Below script allows to create multiple users.<br>
Usernames will be generated in a prefix-number pattern (i.e. user-1).<br>
By setting the following variables the name and number of users can be customized.<br>
A default password is also configurable.

``` bash
# Prefix for username
export USER_NAME_PREFIX="user-"
# Password for all users
export USER_NUMBER_START=1
export USER_COUNT=5
export USER_PASSWORD="Tibco@Demo2026"
```

``` bash

for i in $(seq -w $USER_NUMBER_START $USER_COUNT); do
    USERNAME="$USER_NAME_PREFIX$i"
    
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
```

Each user will receive:

* A fresh home directory
* Files from `/etc/skel`
* GNOME defaults from dconf
* A separate RDP session

---

## Step 5: Validate xrdp Session Configuration

Ensure xrdp launches the correct desktop session.

### Per-User Session (Optional)

```bash
echo "gnome-session" > ~/.xsession
```

### System-Wide Default

```bash
sudo update-alternatives --config x-session-manager
```

Verify services:

```bash
sudo systemctl status xrdp
sudo systemctl status xrdp-sesman
```

---

## Step 6 (Optional): Lock Down Desktop Settings

To prevent users from changing critical desktop settings, use dconf locks.

### Create Lock File

```bash
sudo mkdir -p /etc/dconf/db/local.d/locks
sudo nano /etc/dconf/db/local.d/locks/desktop
```

Example locked keys:

```
/org/gnome/desktop/interface/gtk-theme
/org/gnome/shell/extensions
```

Apply locks:

```bash
sudo dconf update
```

---

## What Not to Do

* Do not clone full home directories
* Do not share a single Linux user account
* Do not copy `.config/dconf/user`
* Do not place secrets or sockets in `/etc/skel`

---

## Result

This setup provides:

* A stable, repeatable RDP user experience
* Clean separation between users
* Easy future expansion (add user → done)

This model closely mirrors a traditional Windows RDS host, adapted for Ubuntu and xrdp.
