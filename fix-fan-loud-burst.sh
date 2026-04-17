#!/bin/bash

set -e

echo "======================================"
echo "Steam Deck Fan Config (SAFE MODE)"
echo "======================================"

CONFIG_SRC="/usr/share/jupiter-fan-control/jupiter-fan-control-config.yaml"
CONFIG="$HOME/jupiter-fan-control-config.yaml"
BACKUP="$HOME/jupiter-fan-control-config.yaml.bak"

# -------------------------------
# 1. Copy config
# -------------------------------
echo "[1/6] Copying config..."
cp "$CONFIG_SRC" "$CONFIG"

# -------------------------------
# 2. Verify current values
# -------------------------------
echo "[2/6] Verifying current values..."

loop_value=$(grep -E "^loop_interval:" "$CONFIG" | awk '{print $2}')
ratio_value=$(grep -E "^control_loop_ration:" "$CONFIG" | awk '{print $2}')

echo "Current loop_interval: $loop_value"
echo "Current control_loop_ration: $ratio_value"

# Expected values check
if [[ "$loop_value" != "0.2" ]]; then
    echo "ERROR: Unexpected loop_interval value ($loop_value)"
    echo "Aborting for safety."
    exit 1
fi

if [[ "$ratio_value" != "5" ]]; then
    echo "ERROR: Unexpected control_loop_ration value ($ratio_value)"
    echo "Aborting for safety."
    exit 1
fi

echo "Values verified OK"

# -------------------------------
# 3. Backup file
# -------------------------------
echo "[3/6] Creating backup..."
cp "$CONFIG" "$BACKUP"

# -------------------------------
# 4. Modify values
# -------------------------------
echo "[4/6] Applying changes..."

sed -i 's/loop_interval: *0.2/loop_interval: 0.25/' "$CONFIG"
sed -i 's/control_loop_ration: *5/control_loop_ration: 4/' "$CONFIG"

# -------------------------------
# 5. Final verification
# -------------------------------
echo "[5/6] Verifying changes..."

new_loop=$(grep -E "^loop_interval:" "$CONFIG" | awk '{print $2}')
new_ratio=$(grep -E "^control_loop_ration:" "$CONFIG" | awk '{print $2}')

echo "New loop_interval: $new_loop"
echo "New control_loop_ration: $new_ratio"

if [[ "$new_loop" != "0.25" || "$new_ratio" != "4" ]]; then
    echo "ERROR: Modification failed"
    echo "Restoring backup..."
    cp "$BACKUP" "$CONFIG"
    exit 1
fi

echo "Changes verified OK"

# -------------------------------
# 6. Apply to system
# -------------------------------
echo "[6/6] Applying system changes..."

sudo steamos-readonly disable
sudo cp "$CONFIG" "$CONFIG_SRC"
sudo steamos-readonly enable

sudo systemctl restart jupiter-fan-control.service

echo "======================================"
echo "DONE - Safe update applied successfully"
echo "======================================"