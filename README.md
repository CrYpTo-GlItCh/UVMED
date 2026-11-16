# Universal FiveM Environment Deployer (`UVMED`)

A robust, automated Bash deployment script designed for Linux environments (`gsm` user context) to quickly provision, configure, and update isolated FiveM server instances running with txAdmin and MariaDB.

---

## Features

* **Flexible Database Protection Levels:** Choose between **Persistent** (production/public safety to protect existing data) and **Volatile** (development/testing environments that automatically wipe and recreate the database on deploy).
* **Automated Directory & Backup Management:** Automatically detects existing server directories, isolates them, and backs up critical assets (`server.cfg` and the `resources` folder) with a timestamped backup prefix.
* **Firewall Configuration:** Automatically opens and configures required TCP and UDP ports via `UFW` for both game traffic and txAdmin.
* **Artifact Management:** Pulls and extracts the latest designated FiveM server artifacts directly from a provided download URL.
* **Systemd Service Integration:** Dynamically generates, reloads, and enables a dedicated `systemd` service for the environment with integrated txAdmin environment variables and MariaDB dependency linking.
* **TxAdmin PIN Retrieval:** Automatically pauses post-deployment to let txAdmin initialize, then outputs the recent journal logs to capture the initial setup PIN.

---

## Interactive Prompts Guide

When you run the script, it will step through the following configuration prompts:

1. **Database Protection Level (`ENV_TYPE`):**
* `1` — Persistent (Safeguards database from being wiped)
* `2` — Volatile (Wipes database clean on deploy)


2. **Environment Label (`BRANCH`):** Short name/label for the environment (e.g., `Main`, `Public`, `Dev`).
3. **Target Folder Name (`DIR_NAME`):** Subfolder name inside `/home/gsm/FXServer/` (e.g., `server`, `pub`, `dev`).
4. **Game Port (`GAME_PORT`):** Main FiveM game port (default is usually `30120`).
5. **txAdmin Port (`TX_PORT`):** Web management panel port (default is usually `40120`).
6. **Database Name (`DB_NAME`):** The MySQL/MariaDB database instance name for this branch.
7. **Global GSM Database Password (`DB_PASS`):** Password for the `gsm` MySQL user (hidden input).
8. **Systemd Service Name (`SVC`):** Unique system service identifier (e.g., `fivem`, `fivem-pub`, `fivem-dev`).
9. **FiveM Artifact Download URL (`ARTIFACT_URL`):** Direct link to the FXServer artifact tarball (`.tar.xz`) from the official FiveM artifact server.

---

## Step-by-Step Execution Workflow

1. **Database Provisioning:** Secures MariaDB user privileges and handles database creation or resetting based on your chosen protection level.
2. **Configuration Backup:** Safely backs up existing configurations and resources into a timestamped directory (e.g., `_backup_YYYYMMDD_HHMMSS`) if the target folder already exists.
3. **UFW Firewall Rules:** Automatically allows TCP/UDP traffic for your game port and TCP traffic for your txAdmin port.
4. **Directory & Service Prep:** Creates target folder paths under `gsm` ownership and halts any running instances of the specified system service.
5. **Artifact Deployment:** Downloads, extracts, and cleans up the requested FiveM server build artifacts.
6. **Service Registration & Startup:** Generates a custom `systemd` service configuration file (`/etc/systemd/system/[SVC].service`), reloads daemon configurations, enables auto-start, and restarts MariaDB and your server instance.
7. **PIN Display:** Waits 30 seconds for txAdmin to spin up and prints out the live system logs so you can copy your setup PIN.

---

## Requirements

* Linux Environment (tested on Ubuntu/Debian-based systems with `systemd` and `ufw`)
* MariaDB / MySQL server installed
* `sudo` privileges and a dedicated `gsm` user setup on the host system

---

## Support Project Evolution

Fuel our hardware and game servers:

* **[PayPal](https://paypal.me/iQuantum)** (FIAT / USD)
* **Bitcoin (BTC)**: `3JNvWL6hSaF3kMVKydfRhfrt82wXDDcaBV` (Standard Network)
* **Ethereum (ETH)**: `0x314523ca487b9BDf158c2072701bdCfA89AbB0e2` (ETH Network)
* **USD Coin (USDC)**: `0x4cc71b7c65eF753B8f497EBFb87eae40739a29F3` (ETH Network)
* **Dogecoin (DOGE)**: `DDVRVa3BcTAb2UC7mEEXmT3wJmViKGMsP7` (Dogecoin Network)
* **Ripple (XRP)** (Ripple Network — *Memo Required*):
  * **Address:** `rw2ciyaNshpHe7bCHo4bRWq6pqqynnWKQg`
  * **Memo:** `4218899529`
