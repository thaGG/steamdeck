# Setup Dual-Boot

Tip!: Connect mouse and keyboard.

# Requirements

- Boot Manager: hold **Volume Down** and click the **Power Button**, when you hear the chime, let go of the **Power** button, and you'll be booted into the Boot Manager.
- Rufus: [https://rufus.ie/en/#download](https://rufus.ie/en/#download)
- SteamOS Recovery image: [https://store.steampowered.com/steamos/download/?ver=steamdeck&snr=100601___](https://store.steampowered.com/steamos/download/?ver=steamdeck&snr=100601___)
- Windows Media Creation Tool: [https://www.microsoft.com/nl-nl/software-download/windows11](https://www.microsoft.com/nl-nl/software-download/windows11)
- GParted: [https://gparted.org/download.php](https://gparted.org/download.php)
- rEFInd for SteamDeck: [https://github.com/jlobue10/SteamDeck_rEFInd](https://github.com/jlobue10/SteamDeck_rEFInd)


# 1 - Install SteamOS (optional)

SteamOS Installation and Repair: [https://help.steampowered.com/en/faqs/view/65B4-2AA3-5F37-4227](https://help.steampowered.com/en/faqs/view/65B4-2AA3-5F37-4227)

- Download the SteamOS Recovery image.
- Prepare a USB key (8GB minimum) with the recovery image using **Rufus**.
- Reboot into the **Boot Manager** and select USB device.
- Once booted you will be in a desktop environment, you can navigate using trackpad and trigger, touchscreen, or mouse.
- Select the **Wipe Device & Install SteamOS** option on the desktop. This will fully wipe your device and install stock SteamOS.
- Once it's done installing, reboot and you will be in the SteamOS welcome experience.
- Complete the setup and shutdown.

# 2 - Prepare Disk

- Download GParted.
- Prepare a USB key with **Rufus**.
- Reboot into the **Boot Manager** and select USB device.
- Start GParted Live.
- Select the **HOME** partition and resize and apply.
- Select the **unallocated** space and select **new**, create as **primary partition** and change filesystem to **ntfs**. Add and apply.
- Exit GParted and Shutdown.

# 3 - Install Windows

- Download and create an ISO using Media Creation Tool.
- Prepare a USB key with **Rufus**.
- Reboot into the **Boot Manager** and select USB device.
- Start the Windows installation
- During the installation at storage location selection, select the created partition and remove it. Now select it again to continue the setup.
- After completion shutdown.

# 4 - Repair SteamOS boot

Instruction video: [https://www.youtube.com/watch?v=eUDbLkHDeGY](https://www.youtube.com/watch?v=eUDbLkHDeGY) starting at 01:12.

- Use USB device with SteamOS Recovery image.
- Reboot into the **Boot Manager** and select USB device.
- Once in dekstop environment, open **Konsole**
- commands to check partitions:
    lsblk
        (nvme0n1 not showing partitions)
    sudo fdisk -l /dev/nvme0n1 (queries intrenal SSD)
        (It shows message **The primary GPT table is corrupted, but the backup appears OK, so that will be used.**)
- command: sudo fdisk /dev/nvme0n1
    enter **p**
    enter **w**
    quit
- command: lsblk
    (It is now showing the partitions)
- command: poweroff

# 4 - Install Boot Manager

Source: [https://github.com/jlobue10/SteamDeck_rEFInd](https://github.com/jlobue10/SteamDeck_rEFInd)

- Reboot into the **Boot Manager**.
- In the Boot Manager, boot from the 'SteamOS'
- Go to STEAM -> Power -> Switch to Desktop
