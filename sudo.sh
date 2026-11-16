echo -e "\n======================================="
echo -e "   Universal fiVeM Environment Deployer"
echo -e "======================================="
echo "Select the database protection level for this branch:"
echo "1) Persistent (Production / Public - Safeguards database from being wiped)"
echo "2) Volatile   (Development - Wipes database clean on deploy)"
read -p "Protection Level (1-2): " ENV_TYPE

if [[ "$ENV_TYPE" != "1" && "$ENV_TYPE" != "2" ]]; then
    echo "Invalid selection. Aborting."
    return 2>/dev/null || exit 1
fi

echo -e "\n--- Define Naming Schema & Ports ---"
read -p "Environment Label (e.g., Main, Public, Dev): " BRANCH
read -p "Target folder name inside /home/gsm/FXServer/ (e.g., server, pub, dev): " DIR_NAME
read -p "Game Port (e.g., 30120): " GAME_PORT
read -p "txAdmin Port (e.g., 40120): " TX_PORT
read -p "Database Name: " DB_NAME
read -s -p "Global GSM Database Password: " DB_PASS
echo ""
read -p "Systemd Service Name (e.g., fivem, fivem-pub, fivem-dev): " SVC
read -p "FiveM Artifact Download URL: " ARTIFACT_URL

DIR="/home/gsm/FXServer/$DIR_NAME"

echo -e "\n[1/6] Securing Database for $BRANCH ($DB_NAME)..."
if [ "$ENV_TYPE" == "2" ]; then
    sudo mariadb -e "DROP DATABASE IF EXISTS $DB_NAME;"
fi
sudo mariadb -e "CREATE DATABASE IF NOT EXISTS $DB_NAME; CREATE USER IF NOT EXISTS 'gsm'@'localhost'; ALTER USER 'gsm'@'localhost' IDENTIFIED BY '$DB_PASS'; GRANT ALL PRIVILEGES ON *.* TO 'gsm'@'localhost'; FLUSH PRIVILEGES;"

echo "[2/6] Backing up existing configurations..."
if [ -d "$DIR" ]; then
    BACKUP_PATH="${DIR}_backup_$(date +%Y%m%d_%H%M%S)"
    sudo -u gsm mkdir -p "$BACKUP_PATH"
    sudo find "$DIR" -name "server.cfg" -exec cp {} "$BACKUP_PATH/" \; 2>/dev/null || true
    sudo find "$DIR" -type d -name "resources" -exec cp -r {} "$BACKUP_PATH/" \; 2>/dev/null || true
    echo " -> Old resources and configs saved to: $BACKUP_PATH"
else
    echo " -> No existing directory found. Skipping backup."
fi

echo "[3/6] Configuring Firewall..."
sudo ufw allow $GAME_PORT/tcp >/dev/null
sudo ufw allow $GAME_PORT/udp >/dev/null
sudo ufw allow $TX_PORT/tcp >/dev/null
sudo ufw reload >/dev/null

echo "[4/6] Preparing Directories & Stopping Services..."
sudo -u gsm mkdir -p $DIR
sudo systemctl stop $SVC 2>/dev/null || true

echo "[5/6] Downloading and Extracting Artifact..."
sudo -u gsm curl -sSL "$ARTIFACT_URL" -o $DIR/fx.tar.xz
sudo -u gsm tar -xf $DIR/fx.tar.xz -C $DIR/
rm -f $DIR/fx.tar.xz

echo "[6/6] Building & Refreshing Systemd Services ($SVC)..."
echo -e "[Unit]\nDescription=FiveM $BRANCH Server with txAdmin\nAfter=network.target mariadb.service\n\n[Service]\nType=simple\nUser=gsm\nWorkingDirectory=$DIR\nEnvironment=\"TXHOST_TXA_PORT=$TX_PORT\"\nEnvironment=\"TXHOST_DATA_PATH=$DIR/txData\"\nExecStart=$DIR/run.sh\nRestart=on-failure\nRestartSec=5\nStandardOutput=inherit\nStandardError=inherit\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/$SVC.service > /dev/null

sudo systemctl daemon-reload
sudo systemctl reset-failed $SVC 2>/dev/null || true
sudo systemctl enable $SVC >/dev/null 2>&1
sudo systemctl restart $SVC
sudo systemctl restart mariadb

echo -e "\n=================================================================="
echo -e "$BRANCH environment successfully provisioned on port $TX_PORT!"
echo -e "Waiting 30 seconds for txAdmin to generate your confirmation PIN..."
echo -e "==================================================================\n"
sleep 30
sudo journalctl -u $SVC -n 100 --no-pager
