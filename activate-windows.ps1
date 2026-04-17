param(
    [string]$KmsServer = "158.101.213.238",
    [string]$LogPath = "C:\Temp\windows-kms.log"
)

# -------------------------------
# Logging
# -------------------------------
function Write-Log {
    param([string]$Message)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$timestamp $Message"

    Write-Host $line
    Add-Content -Path $LogPath -Value $line
}

# -------------------------------
# Windows GVLK mapping
# -------------------------------
$WindowsGVLK = @{
    "Windows 10 Pro"                 = "W269N-WFGWX-YVC9B-4J6C9-T83GX"
    "Windows 10 Enterprise"          = "NPPR9-FWDCX-D2C8J-H872K-2YT43"
    "Windows 10 Education"           = "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2"

    "Windows 11 Pro"                 = "W269N-WFGWX-YVC9B-4J6C9-T83GX"
    "Windows 11 Enterprise"          = "NPPR9-FWDCX-D2C8J-H872K-2YT43"
    "Windows 11 Education"           = "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2"

    "Windows Server 2019 Standard"    = "N69G4-B89J2-4G8F4-WWYCC-J464C"
    "Windows Server 2019 Datacenter"  = "WMDGN-G9PQG-XVVXX-R3X43-63DFG"

    "Windows Server 2022 Standard"    = "VDYBN-27WPP-V4HQT-9VMD4-VMK7H"
    "Windows Server 2022 Datacenter"  = "WX4NM-KYWYW-QJJR4-XV3QB-6VM33"

    "Windows Server 2025 Standard"    = "TVRH6-WHNXV-R9WG3-9XRFY-MY832"
    "Windows Server 2025 Datacenter"  = "D764K-2NDRG-47T6Q-P8T8W-YP6DF"
}

# -------------------------------
# Detect Windows edition
# -------------------------------
function Get-WindowsEdition {
    $os = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

    $productName = $os.ProductName
    $editionID   = $os.EditionID

    Write-Log "Detected OS: $productName ($editionID)"

    if ($productName -match "Windows 10") {
        if ($editionID -match "Enterprise") { return "Windows 10 Enterprise" }
        if ($editionID -match "Education")  { return "Windows 10 Education" }
        return "Windows 10 Pro"
    }

    if ($productName -match "Windows 11") {
        if ($editionID -match "Enterprise") { return "Windows 11 Enterprise" }
        if ($editionID -match "Education")  { return "Windows 11 Education" }
        return "Windows 11 Pro"
    }

    if ($productName -match "Windows Server 2025") {
        if ($editionID -match "Datacenter") { return "Windows Server 2025 Datacenter" }
        return "Windows Server 2025 Standard"
    }

    if ($productName -match "Windows Server 2022") {
        if ($editionID -match "Datacenter") { return "Windows Server 2022 Datacenter" }
        return "Windows Server 2022 Standard"
    }

    if ($productName -match "Windows Server 2019") {
        if ($editionID -match "Datacenter") { return "Windows Server 2019 Datacenter" }
        return "Windows Server 2019 Standard"
    }

    return $null
}

# -------------------------------
# Activation logic
# -------------------------------
function Activate-Windows {
    $edition = Get-WindowsEdition

    if (-not $edition) {
        Write-Log "Unsupported Windows edition"
        exit 1
    }

    $key = $WindowsGVLK[$edition]

    if (-not $key) {
        Write-Log "No GVLK found for: $edition"
        exit 1
    }

    Write-Log "Activating Windows edition: $edition"
    Write-Log "Using GVLK: $key"

    $slmgr = "$env:SystemRoot\System32\slmgr.vbs"

    Write-Log "Installing product key..."
    cscript.exe $slmgr /ipk $key | Out-Null

    Write-Log "Setting KMS server..."
    cscript.exe $slmgr /skms $KmsServer | Out-Null

    Write-Log "Activating Windows..."
    cscript.exe $slmgr /ato | Out-Null

    Write-Log "License status:"
    cscript.exe $slmgr /dlv

    Write-Log "Windows activation completed"
}

# -------------------------------
# MAIN
# -------------------------------
try {
    Write-Log "===== START WINDOWS KMS ACTIVATION ====="

    Activate-Windows

    Write-Log "===== SUCCESS ====="
}
catch {
    Write-Log "ERROR: $_"
    exit 1
}