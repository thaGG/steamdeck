# Post-Configuration SteamOS

# Boost GPU VRAM

*   Boot into `**Bios Menu**`  
    hold `**Volume UP**` and click the `**Power Button**`, when you hear the chime, let go of the `**Power**` button, and you'll be booted into the `**Bios Menu**`
*   Select `**Setup Utility**`
*   Select `**Advanced**`
*   Select `**UMA Frame buffer Size**`
*   Select `**4G**`
*   `**Save and exit**`

# Fix Loud Fan Bursts

URL: [https://www.pcgamesn.com/how-to-fix-loud-steam-deck-fans](https://www.pcgamesn.com/how-to-fix-loud-steam-deck-fans)

*   Enter desktop mode by pressing the Steam button, going to 'Power' and then choosing 'Switch to Desktop'
*   You'll then need to give yourself a password so you can go into '`**sudo**`' - to do this, open the Konsole command and type in `**passwd**` without the quotation marks
*   Using the Konsole, copy the Steam Deck's fan config file using (tab will allow for auto-completion):   
    `**cp /usr/share/jupiter-fan-control/jupiter-fan-control-config.yaml ~**`
*   Once copied, you'll then need to open the file in the Home folder through the device's text editor, KWrite
*   Change loop\_interval from **0.2** to **0.2**5, and control\_loop\_ration from **5** to **4**. Make sure to save it once that's done
*   Go back into Konsole and type  
    `**sudo steamos-readonly disable**`  
    to make the file writable
*   Copy the config file you've amended by typing the following in the command:   
    `**sudo cp ~/jupiter-fan-control-config.yaml /usr/share/jupiter-fan-control/**`
*   Type   
    `**sudo steamos-readonly enable**`  
    to make the file read-only again
*   It's then recommended to go back into Gaming Mode and restart the updated fan control by toggling the UI switch.   
    However, if you want to stay in desktop mode, use  
    `**sudo systemctl restart jupiter-fan-control.service**`"

# SteamDeck\_rEFInd

URL: [https://github.com/jlobue10/SteamDeck_rEFInd](https://github.com/jlobue10/SteamDeck_rEFInd)

This is a simple rEFInd install script for the Steam Deck meant to provide easy dual boot setup when using both SteamOS and Windows on the internal NVMe. Since the initial version of this script, optional support has been added for Windows from the SD card, Batocera from the SD card and an example boot stanza for Ubuntu (or other Ubuntu based flavors / distros). The options really are pretty limitless, but require some understanding and manual edits to the `refind.conf` file.

### Necessary steps for _reinstalling Windows_

*   You will need to re-enable the Windows EFI boot entry to allow the Windows installation process to complete unhindered. Replace YYYY in the following command with the Windows EFI entry number to re-enable the Windows EFI boot entry. The script will disable it again later, if it is re-ran after successful installation. Please be aware that this disabling step requires SteamOS recovery image for SteamOS 3.4+ (at least for now).  
    `sudo efibootmgr -b YYYY -a`

### Additional Windows considerations _(corrupted display on boot into Windows)_

*   There is a newer, better fix than what was previously documented that actually prevents this issue in the first place. You can run a specific `bcdedit` command from either a command prompt or powershell (both require as administrator). This command should be run as soon as possible on a new Windows installation if a user plans to use rEFInd.
*   Command prompt command:  
    `bcdedit.exe -set {globalsettings} highestmode on`
*   Powershell command:  
    `bcdedit /set "{globalsettings}" highestmode on`

# Cryo Utilities

URL: [https://github.com/CryoByte33/steam-deck-utilities](https://github.com/CryoByte33/steam-deck-utilities)

Scripts and utilities to improve performance and manage storage on the Steam Deck. (May work with other Linux distros.)

## Functionality

*   One-click set-to-recommended settings
*   One-click revert-to-stock settings
*   Swap Tuner
    *   Swap File Resizer + Recovery
    *   Swappiness Changer
*   Memory Parameter Tuning
    *   HugePages Toggle
    *   Compaction Proactiveness Changer
    *   HugePage Defragmentation Toggle
    *   Page Lock Unfairness Changer
    *   Shared Memory (shmem) Toggle
*   Storage Manager
    *   Sync shadercache and compatdata to the same location the game is installed
    *   Delete shadercache and compatdata for whichever games you select
    *   Delete the shadercache and compatdata for all uninstalled games with a single click
*   Full CLI mode

# Decky Loader

URL: [https://github.com/SteamDeckHomebrew/decky-loader](https://github.com/SteamDeckHomebrew/decky-loader)

Decky Loader is a homebrew plugin launcher for the Steam Deck. It can be used to [stylize your menus](https://github.com/suchmememanyskill/SDH-CssLoader), [change system sounds](https://github.com/EMERALD0874/SDH-AudioLoader), [adjust your screen saturation](https://github.com/libvibrant/vibrantDeck), [change additional system settings](https://github.com/NGnius/PowerTools), and [more](https://plugins.deckbrew.xyz/).

## Features

🧹 Clean injecting and loading of multiple plugins.  
🔒 Stays installed between system updates and reboots.  
🔗 Allows two-way communication between plugins and the loader.  
🐍 Supports Python functions run from TypeScript React.  
🌐 Allows plugins to make fetch calls that bypass CORS completely.