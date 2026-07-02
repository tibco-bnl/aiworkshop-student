# Workshop Preparation

This guide is fully self-contained and describes the complete preparation flow for a workshop machine.

## Step 0: 🔐 Log In As tibco User

1. Log in to the workshop machine as user `tibco`.
2. Use the workshop machine details from the workshop machine Google Sheet.

---

## Step 1: 🧹 Delete Old Users That Are No Longer Needed

1. List existing home directories:

```bash
ll /home
```

2. Identify old workshop users that should be removed.
3. Go to the scripts folder:

```bash
cd /opt/tibco/scripts
```

4. Check delete script options:

```bash
./delete-user.sh --help
```

5. Delete users.

Delete one default user pattern (for example `user01`):

```bash
./delete-user.sh
```

Delete a range (example removes `participant01` through `participant12`):

```bash
./delete-user.sh -p participant -s 1 -c 12
```

The delete command used by the script is:

```bash
sudo userdel -r [username]
```

---

## Step 2: 👥 Create New Users

1. Ensure you are in the scripts folder:

```bash
cd /opt/tibco/scripts
```

2. Check create script options:

```bash
./create-user.sh --help
```

3. Create users.

Create one user with defaults:

```bash
./create-user.sh
```

Create a range (example creates `participant01` through `participant12`):

```bash
./create-user.sh -p participant -s 1 -c 12 -P 'Tibco2026'
```

Default create behavior:

- Prefix: `user`
- Start number: `1`
- Count: `1`
- Password: `Tibco2026`
- Username format: zero-padded (example: `user01`)

---

## Step 3: 🌐 Add Participant IP Addresses To Azure Network Security Group

1. Open the Azure portal.
2. Search for `network security group`.
3. Open `NL-AI-Workshop-Desktop-nsg`.
4. Go to **Settings** -> **Inbound security rules**.
5. Filter for rule `WorkshopParticipants`.
6. Edit the rule and update the **Source** field with participant IP addresses.
7. For multiple IPs, enter them as a comma-separated list.
8. Save the rule.

Example source value:

`145.22.10.11,145.22.10.12,145.22.10.13`

---

