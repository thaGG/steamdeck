# Windows Post-Configuration

## Drivers

*   **APU driver** - [download here](https://steamcommunity.com/linkfilter/?u=https%3A%2F%2Fsteamdeck-packages.steamos.cloud%2Fmisc%2Fwindows%2Fdrivers%2FAerith_Sephiroth_Windows_Driver_2309131113.zip), run setup.exe to install.
*   **Wi-Fi driver** - [download here](https://steamcommunity.com/linkfilter/?u=https%3A%2F%2Fsteamdeck-packages.steamos.cloud%2Fmisc%2Fwindows%2Fdrivers%2FRTLWlanE_WindowsDriver_2024.0.10.137_Drv_3.00.0039_Win11.L.zip), run install.bat to install.
*   **Bluetooth driver** - [download here](https://steamcommunity.com/linkfilter/?u=https%3A%2F%2Fsteamdeck-packages.steamos.cloud%2Fmisc%2Fwindows%2Fdrivers%2FRTBlueR_FilterDriver_1041.3005_1201.2021_new_L.zip), run installdriver.cmd to install.
*   **SD Card reader driver** - [download here](https://steamcommunity.com/linkfilter/?u=https%3A%2F%2Fsteamdeck-packages.steamos.cloud%2Fmisc%2Fwindows%2Fdrivers%2FBayHub_SD_STOR_installV3.4.01.89_W10W11_logoed_20220228.zip), run setup.exe to install.
*   **Audio drivers**
    *   [Download driver 1/2](https://steamcommunity.com/linkfilter/?u=https%3A%2F%2Fsteamdeck-packages.steamos.cloud%2Fmisc%2Fwindows%2Fdrivers%2Fcs35l41-V1.2.1.0.zip), right click **cs35l41.inf** and select Install. _(last updated October 10, 2022)_
    *   [Download driver 2/2](https://steamcommunity.com/linkfilter/?u=https%3A%2F%2Fsteamdeck-packages.steamos.cloud%2Fmisc%2Fwindows%2Fdrivers%2FNAU88L21_x64_1.0.6.0_WHQL%2520-%2520DUA_BIQ_WHQL.zip), right click **NAU88L21.inf** and select Install.
    *   These INF files will show up as 'Setup Information' type files in File Explorer.
    *   On Windows 11, right click and select 'Show More Options' to see the 'Install' option.
    *   Don't forget to get the updated APU driver above for audio support.
    *   _This driver is updated as of November 17th, 2023_

## Configuration

*   Steam Deck Tools: [ayufan/steam-deck-tools](https://github.com/ayufan/steam-deck-tools/releases)

## Software

*   XBOX : `winget install 9MV0B5HZVK9Z`
*   Steam : `winget install -e --id Valve.Steam`
*   Microsoft Visual Studio Code: `winget install -e --id Microsoft.VisualStudioCode`
*   Git for Windows: `winget install --id Git.Git -e --source winget`