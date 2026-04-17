#!/bin/bash

set -e

REPO_URL="https://github.com/thaGG/steamdeck.git"
REPO_DIR="/home/deck/steamdeck"
SCRIPT_PATH="$REPO_DIR/git-sync-steamdeck.sh"
SERVICE_PATH="/etc/systemd/system/git-sync.service"
TIMER_PATH="/etc/systemd/system/git-sync.timer"
LOG_FILE="/var/log/git-sync-steamdeck.log"

echo "Installing Git sync system..."

# -------------------------------
# 1. Create sync script
# -------------------------------
sudo tee "$SCRIPT_PATH" > /dev/null <<EOF
#!/bin/bash

REPO_URL="$REPO_URL"
REPO_DIR="$REPO_DIR"
LOG_FILE="$LOG_FILE"

log() {
    echo "\$(date '+%Y-%m-%d %H:%M:%S') - \$1" >> "\$LOG_FILE"
}

# Wait for network
for i in {1..30}; do
    ping -c 1 8.8.8.8 >/dev/null 2>&1 && break
    sleep 2
done

if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    log "No network available, aborting"
    exit 1
fi

cd "/home/deck" || exit 1

if [ -d "\$REPO_DIR/.git" ]; then
    log "Updating repo"

    cd "\$REPO_DIR" || exit 1

    branch=\$(git remote show origin | awk '/HEAD branch/ {print \$NF}')
    branch=\${branch:-main}

    git fetch origin >> "\$LOG_FILE" 2>&1
    git reset --hard "origin/\$branch" >> "\$LOG_FILE" 2>&1

    log "Update complete"
else
    log "Cloning repo"
    git clone "\$REPO_URL" "\$REPO_DIR" >> "\$LOG_FILE" 2>&1
    log "Clone complete"
fi
EOF

sudo chmod +x "$SCRIPT_PATH"

# -------------------------------
# 2. Create systemd service
# -------------------------------
sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=SteamDeck Git Sync at Boot
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH
EOF

# -------------------------------
# 3. Create systemd timer
# -------------------------------
sudo tee "$TIMER_PATH" > /dev/null <<EOF
[Unit]
Description=Run Git sync once at boot

[Timer]
OnBootSec=3min
Persistent=true
Unit=git-sync.service

[Install]
WantedBy=timers.target
EOF

# -------------------------------
# 4. Enable systemd
# -------------------------------
sudo systemctl daemon-reload
sudo systemctl enable git-sync.timer
sudo systemctl start git-sync.timer

echo "Installation complete."
echo "Log file: $LOG_FILE"