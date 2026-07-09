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
5. (Optional) Lock down critical desktop settings


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

### Create one or more users using the provided script

Use the script in this repository to create workshop users directly on the student workstation.

Script location:

```bash
setup/student-workstation/code/scripts/create-user.sh
```

From the repository root, run:

```bash
chmod +x setup/student-workstation/code/scripts/create-user.sh
./setup/student-workstation/code/scripts/create-user.sh --help
```

Create one user (defaults):

```bash
./setup/student-workstation/code/scripts/create-user.sh
```

Default behavior:

* Prefix: `user`
* Start number: `1`
* Count: `1`
* Password: `Tibco2026`
* Resulting username format: zero-padded, e.g. `user01`

Create multiple users (example):

```bash
./setup/student-workstation/code/scripts/create-user.sh -p participant -s 1 -c 6 -P 'Tibco2026'
```

This creates: `participant01` to `participant06`.

Available options:

* `-p`, `--prefix`: user name prefix
* `-s`, `--start`: starting number
* `-c`, `--count`: number of users
* `-P`, `--password`: password for created users
* `-h`, `--help`: show usage

Each user will receive:

* A fresh home directory
* Files from `/etc/skel`
* GNOME defaults from dconf
* A separate RDP session

---

## Step 5 (Optional): Lock Down Desktop Settings

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
