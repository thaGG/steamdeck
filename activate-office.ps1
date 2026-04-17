param(
    [string]$KmsServer = "158.101.213.238",
    [string]$LogPath = "C:\Temp\office-activation.log"
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
# GVLK Mapping
# -------------------------------
$GVLK = @{
    "ProPlus2024" = "XJ2XN-FW8RK-P4HMP-DKDBV-GCVGB"
    "ProPlus2021" = "FXYTK-NJJ8C-GB6DW-3DYQT-6F7TH"
    "ProPlus2019" = "NMMKJ-6RK4F-KMJVX-8D9MJ-6MWKP"
    "ProPlus2016" = "XQNVK-8JYDB-WJ9W3-YJ8YR-WFG99"

    "Standard2024" = "V28N4-JG22K-W66P8-VTMGK-H6HGR"
    "Standard2021" = "KDX7X-BNVR8-TXXGX-4Q7Y8-78VT3"
    "Standard2019" = "6NWWJ-YQWMR-QKGCB-6TMB3-9D9HK"
    "Standard2016" = "JNRGM-WHDWX-FJJG3-K47QV-DRTFM"

    "VisioPro2024" = "B7TN8-FJ8V3-7QYCP-HQPMV-YY89G"
    "VisioPro2021" = "KNH8D-FGHT4-T8RK3-CTDYJ-K2HT4"
    "VisioPro2019" = "9BGNQ-K37YR-RQHF2-38RQ3-7VCBB"

    "ProjectPro2024" = "FTNWT-C6WBT-8HMGF-K9PRX-QV9H8"
    "ProjectPro2021" = "FTNWT-C6WBT-8HMGF-K9PRX-QV9H8"
    "ProjectPro2019" = "B4NPR-3FKK7-T2MBV-FRQ4W-PKD2B"
}

# -------------------------------
# Get installed product IDs
# -------------------------------
function Get-InstalledProductIds {
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\ClickToRun\Configuration"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            $cfg = Get-ItemProperty $path
            if ($cfg.ProductReleaseIds) {
                return ($cfg.ProductReleaseIds -split ",")
            }
        }
    }

    return @()
}

# -------------------------------
# Resolve product → GVLK key
# -------------------------------
function Resolve-GVLK {
    param([string]$ProductId)

    switch -Wildcard ($ProductId) {
        "*ProPlus2024*" { return $GVLK["ProPlus2024"] }
        "*ProPlus2021*" { return $GVLK["ProPlus2021"] }
        "*ProPlus2019*" { return $GVLK["ProPlus2019"] }

        "*Standard2024*" { return $GVLK["Standard2024"] }
        "*Standard2021*" { return $GVLK["Standard2021"] }
        "*Standard2019*" { return $GVLK["Standard2019"] }

        "*VisioPro2024*" { return $GVLK["VisioPro2024"] }
        "*VisioPro2021*" { return $GVLK["VisioPro2021"] }
        "*VisioPro2019*" { return $GVLK["VisioPro2019"] }

        "*ProjectPro2024*" { return $GVLK["ProjectPro2024"] }
        "*ProjectPro2021*" { return $GVLK["ProjectPro2021"] }
        "*ProjectPro2019*" { return $GVLK["ProjectPro2019"] }
    }

    return $null
}

# -------------------------------
# Find ospp.vbs
# -------------------------------
function Get-OSPPPath {
    $roots = @(
        "$env:ProgramFiles\Microsoft Office",
        "$env:ProgramFiles(x86)\Microsoft Office"
    )

    foreach ($root in $roots) {
        if (Test-Path $root) {
            $file = Get-ChildItem -Path $root -Filter ospp.vbs -Recurse -ErrorAction SilentlyContinue |
                    Select-Object -First 1
            if ($file) { return $file.FullName }
        }
    }

    return $null
}

# -------------------------------
# MAIN
# -------------------------------
try {
    $productIds = Get-InstalledProductIds

    if (-not $productIds) {
        throw "No Office products detected"
    }

    Write-Log "Detected products: $($productIds -join ', ')"

    $ospp = Get-OSPPPath
    if (-not $ospp) { throw "ospp.vbs not found" }

    Write-Log "Using ospp: $ospp"

    # Set KMS once
    Write-Log "Setting KMS server..."
    cscript.exe $ospp /sethst:$KmsServer | Out-Null

    foreach ($productId in $productIds) {

        Write-Log "Processing: $productId"

        $key = Resolve-GVLK -ProductId $productId

        if (-not $key) {
            Write-Log "Skipping (no GVLK match)"
            continue
        }

        Write-Log "Applying key: $key"

        cscript.exe $ospp /inpkey:$key | Out-Null

        Write-Log "Activating..."
        cscript.exe $ospp /act | Out-Null
    }

    Write-Log "Final activation status:"
    cscript.exe $ospp /dstatusall

    Write-Log "SUCCESS"
}
catch {
    Write-Log "ERROR: $_"
    exit 1
}