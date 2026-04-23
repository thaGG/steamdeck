#!/bin/bash
echo "Post-configuration script for SteamOS"
echo =======================================
echo 
echo

echo "# Configure Fan Control"
echo "-----------------------"
CONFIG_SRC="/usr/share/jupiter-fan-control/jupiter-fan-control-config.yaml"
CONFIG="$HOME/jupiter-fan-control-config.yaml"
BACKUP="$HOME/jupiter-fan-control-config.yaml.bak"

if [ ! -f "$CONFIG" ]; then
    cp "$CONFIG_SRC" "$CONFIG"
fi

loop_value=$(grep -E "^loop_interval:" "$CONFIG" | awk '{print $2}')
ratio_value=$(grep -E "^control_loop_ration:" "$CONFIG" | awk '{print $2}')

if [[ "$loop_value" == "0.25" && "$ratio_value" == "4" ]]; then
    echo ">> Config already applied. Skipping..."
else
    echo ">> Config not applied yet. Proceeding..."
    if [[ "$loop_value" != "0.2" || "$ratio_value" != "5" ]]; then
        echo "ERROR: Unexpected values detected!"
        echo ">> Aborting to avoid unsafe modification."
        exit 1
    fi
    cp "$CONFIG" "$BACKUP"
    sed -i 's/loop_interval: *0.2/loop_interval: 0.25/' "$CONFIG"
    sed -i 's/control_loop_ration: *5/control_loop_ration: 4/' "$CONFIG"
    sudo steamos-readonly disable
    sudo cp "$CONFIG" "$CONFIG_SRC"
    sudo steamos-readonly enable
    sudo systemctl restart jupiter-fan-control.service
fi

echo "# Install SteamDeck_rEFInd"
echo "--------------------------"
if [ -d "/esp/efi/refind" ] || [ -d "/boot/efi/EFI/refind" ]; then
    echo ">> Already installed. Skipping..."
else
    echo "> Downloading..."
    cd "$HOME"
    rm -rf "$HOME/SteamDeck_rEFInd/"
    git clone https://github.com/jlobue10/SteamDeck_rEFInd
    cd SteamDeck_rEFInd

    echo "> Installing..."
    chmod +x install-GUI.sh
    ./install-GUI.sh
    echo ">> Installation complete!"
    echo

echo "# Install Cryo Utilities"
echo "------------------------"
if [ -d "$HOME/.cryo_utilities" ] || [ -f "$HOME/Desktop/CryoUtilities.desktop" ]; then
    echo ">> Already installed. Skipping..."
else
    URL="https://raw.githubusercontent.com/CryoByte33/steam-deck-utilities/main/InstallCryoUtilities.desktop"
    DEST="$HOME/Desktop/InstallCryoUtilities.desktop"

    echo "> Downloading to Desktop..."
    mkdir -p "$HOME/Desktop"
    curl -fsSL "$URL" -o "$DEST"

    echo "> Launching via desktop environment..."
    chmod +x "$DEST"
    xdg-open "$DEST"

    echo ">> Installation started!"
    echo
fi

echo "# Install Decky Loader"
echo "----------------------"
if [ -d "$HOME/.local/share/decky-loader" ]; then
    echo ">> Decky Loader already installed. Skipping..."
else
    echo "> Installing..."
    curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
    echo ">> Installation complete!"
    echo
fi