# Windows Post-Configuration
# ==========================

# Check for admin rights
# ----------------------

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run this script as Administrator!"
    exit 1
}

# Variables
# ---------
$script:Applications = winget list | Select-Object -Skip 3 |
    Where-Object { $_ -and $_ -notmatch "^-+" } |
        ForEach-Object {
            $cols = ($_ -split '\s{2,}')  # split on multiple spaces
            [PSCustomObject]@{
                Name    = $cols[0]
                Id      = $cols[1]
                Version = $cols[2]
            }
        }

# Functions
# ---------
function Set-RegistryKey {
    param (
        [string]$Path,
        [string]$Name,
        [string]$Value
    )

    try {
        $current = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
    } catch {
        $current = $null
    }

    if ($current -ne $Value) {
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Force
        $changed = $true
    }
}

function Install-Application {
    param (
        [Parameter(Mandatory)]
        [string]$Id
    )

    $pkg = $script:Applications | Where-Object { $_.Id -eq $Id }
    if (-not $pkg) {
        $pkg = $script:Applications | Where-Object { $_.Id -like "*$Id*" }
    }

    Write-Host "> Install   : $Id ($($pkg.Name)) " -NoNewline
    if (-not $pkg) {
        winget install -e --id $Id `
            --accept-package-agreements `
            --accept-source-agreements `
            --silent
        Write-Host ">> Changed" -ForegroundColor Cyan
        $changed = $true
    } else {
        Write-Host ">> OK" -ForegroundColor Green
    }
}

function Install-Software {
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$ProcessName,
        [Parameter(Mandatory)]
        [string]$Installer,
        [string]$Arguments
    )

    Write-Host "> Install   : $Name " -NoNewline

    if (Get-Process | Where-Object { $_.ProcessName -like "*$ProcessName*" }) {
        Write-Host ">> OK" -ForegroundColor Green
    } else {
        $script:downloadFolder = Join-Path $env:USERPROFILE "Downloads"
        $targetFile = Join-Path $downloadFolder $Installer
        Copy-Item -Path ".\downloads\$Installer" -Destination $targetFile -Force
        Start-Process -FilePath $targetFile -ArgumentList $Arguments -Wait

        Write-Host ">> Changed" -ForegroundColor Cyan
        $changed = $true
    }   
}


function Uninstall-Application {
    param (
        [Parameter(Mandatory)]
        [string]$Id,
        [Parameter()]
        [string]$Name
    )

    $pkg = $script:Applications | Where-Object { $_.Id -eq $Id }
    if (-not $pkg) {
        $pkg = $script:Applications | Where-Object { $_.Id -like "*$Id*" }
    }

    If ($Name) {
        Write-Host "> Uninstall : $Name ($($pkg.Name))" -NoNewline
    } else {
          Write-Host "> Uninstall : $Id ($($pkg.Name)) " -NoNewline
    }
    
    if ($pkg) {
        if ($pkg.Id -like "MSIX*" ) {
            # For Microsoft Store apps, use the package family name
            $pkgName = $pkg.Id -replace '^MSIX\\', '' -replace '^Microsoft\.' -replace '_\d+.*'
            $PackageFullName = Get-AppxPackage | Where-Object {$_.Name -like "*$pkgName*"} | Select-Object -ExpandProperty PackageFullName
            if ($PackageFullName) {
                Remove-AppxPackage -Package $PackageFullName -AllUsers -ErrorAction SilentlyContinue    
            }
        } else {
            # For regular apps, use winget
            winget uninstall -e --id $Id --silent
        }
        Write-Host ">> Changed" -ForegroundColor Cyan
        $changed = $true
    } else {
        Write-Host ">> OK" -ForegroundColor Green
    }
}

# Configure Power Settings
# ------------------------

function Start-Configure-PowerSettings {
    Write-Host "> Configure : Power Settings " -NoNewline
    $balancedGUID = "381b4222-f694-41f0-9685-ff5bb260df2e"
    $ultimateGUID = "e9a42b02-d5df-448d-aa00-03f14749eb61"

    $currentScheme = powercfg /getactivescheme
    $currentScheme -match "([a-f0-9\-]{36})" | Out-Null
    $activeGUID = $matches[1].ToLower()

    if ($activeGUID -match $balancedGUID) {
        $output = powercfg -duplicatescheme $ultimateGUID
        $output -match "([a-f0-9\-]{36})" | Out-Null
        $ultimateGUID = $matches[1]

        powercfg -duplicatescheme $ultimateGUID

        # Activate it
        powercfg -setactive $ultimateGUID

        # Disable sleep & timeouts (AC)
        powercfg -change -standby-timeout-ac 0
        powercfg -change -monitor-timeout-ac 0
        powercfg -change -disk-timeout-ac 0

        # Disable sleep & timeouts (Battery)
        powercfg -change -standby-timeout-dc 0
        powercfg -change -monitor-timeout-dc 0
        powercfg -change -disk-timeout-dc 0

        ## Disable hibernation (this also disables Fast Startup)
        powercfg /h off

        # Explicitly set registry value (extra assurance)
        Set-RegistryKey "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" "HiberbootEnabled" "0"

        # Disabling console lock timeout
        powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 0

        # 100% CPU performance
        powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
        powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
        powercfg -setactive SCHEME_CURRENT

        Write-Host ">> Changed" -ForegroundColor Cyan
    } else {
        Write-Host ">> OK" -ForegroundColor Green
    }
}

# Configure Auto-Login
# --------------------
Function Start-Configure-AutoLogin {
    Write-Host "> Enable    : Auto-Login " -NoNewline

    $user = "steamdeck"
    $securePassword = ConvertTo-SecureString "password" -AsPlainText -Force
    $plainPassword = [System.Net.NetworkCredential]::new("", $securePassword).Password

    if (-not (Get-LocalUser -Name $user -ErrorAction SilentlyContinue)) {
        New-LocalUser -Name $user -Password $securePassword -FullName "Auto Logon User" -PasswordNeverExpires:$true
    }

    $policyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $winlogon   = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

    Set-RegistryKey $policyPath "DontDisplayLastUserName" 0
    Set-RegistryKey $winlogon "AutoAdminLogon" "1"
    Set-RegistryKey $winlogon "ForceAutoLogon" "1"
    Set-RegistryKey $winlogon "DefaultUserName" $user
    Set-RegistryKey $winlogon "DefaultPassword" $plainPassword
    Set-RegistryKey $winlogon "DefaultDomainName" $env:COMPUTERNAME

    $currentLock = powercfg /GETACVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 2>$null
    if ($currentLock -notmatch "0x00000000") {
        Write-Host "Disabling console lock timeout"
        powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 0 | Out-Null
        powercfg /SETACTIVE SCHEME_CURRENT | Out-Null
        $changed = $true
    }

    foreach ($name in @("LegalNoticeCaption","LegalNoticeText")) {
        if (Get-ItemProperty -Path $policyPath -Name $name -ErrorAction SilentlyContinue) {
            Write-Host "Removing $name"
            Remove-ItemProperty -Path $policyPath -Name $name
            $changed = $true
        }
    }

    if ($changed) {
        Write-Host ">> Changed" -ForegroundColor Cyan
    }
    else {
        Write-Host ">> OK" -ForegroundColor Green
    }
}

# Configure Taskbar
# -----------------
function Start-Configure-Taskbar {
    Write-Host "> Customize : Taskbar " -NoNewline

    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-RegistryKey $path "SearchboxTaskbarMode" 1
    Set-RegistryKey $path "ShowTaskViewButton" 0

    $regPath = "HKLM:\Software\Policies\Microsoft\Dsh"
    Set-RegistryKey $regPath "AllowNewsAndInterests" 0

    $webPkg = Get-AppxPackage *WebExperience* -ErrorAction SilentlyContinue
    if ($webPkg) {
        Remove-AppxPackage -Package $webPkg.PackageFullName -ErrorAction SilentlyContinue -Verbose -force
        $changed = $true
    }

    # Restart Explorer only if changes were made
    if ($changed) {
        Stop-Process -Name explorer -Force
        Start-Process explorer.exe
        Write-Host ">> Changed" -ForegroundColor Cyan
    }
    else {
        Write-Host ">> OK" -ForegroundColor Green
    }

    Uninstall-Application -Id "9MSSGKG348SP" -Name "MicrosoftWindows.Client.WebExperience"
}

Start-Configure-AutoLogin
Start-Configure-PowerSettings
Start-Configure-Taskbar

# Uninstall Applications
# ----------------------

Uninstall-Application -Id "Microsoft.OutlookForWindows"
Uninstall-Application -Id "Microsoft.BingWeather"
Uninstall-Application -Id "Microsoft.BingNews"
Uninstall-Application -Id "Microsoft.Teams"
Uninstall-Application -Id "Microsoft.GetHelp"
Uninstall-Application -Id "Microsoft.MicrosoftSolitaireCollection"
Uninstall-Application -Id "Microsoft.PowerAutomateDesktop"
Uninstall-Application -Id "Microsoft.WindowsFeedbackHub"
Uninstall-Application -Id "Microsoft.YourPhone"
Uninstall-Application -Id "Microsoft.StartExperiencesApp"

# Install Applications
# --------------------

Install-Application -Id "Microsoft.VisualStudioCode"
Install-Application -Id "Git.Git"
Install-Application -Id "OpenAI.ChatGPT"
Install-Application -Id "9MV0B5HZVK9Z"
Install-Application -Id "Valve.Steam"

# Install Software
# --------------------

Install-Software `
    -Name "Roboform" `
    -ProcessName "robotaskbaricon" `
    -Installer "RoboForm-v9-Setup.exe" `
    -Arguments "/VERYSILENT /NORESTART /SUPPRESSMSGBOXES"

Install-Software `
    -Name "AdGuard" `
    -ProcessName "adguard" `
    -Installer "adguardInstaller.exe" `
    -Arguments "/S"

Install-Software `
    -Name "MiniBin" `
    -ProcessName "minibin" `
    -Installer "MiniBin-6.6.0.0-Setup.exe" `
    -Arguments "/VERYSILENT /NORESTART /SUPPRESSMSGBOXES"