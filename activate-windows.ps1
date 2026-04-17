# Activate Windows using KMS

try {
    Write-Host "Uninstalling current product key..."
    cscript.exe $env:SystemRoot\System32\slmgr.vbs -upk

    Write-Host "Installing new product key..."
    cscript.exe $env:SystemRoot\System32\slmgr.vbs -ipk "NPPR9-FWDCX-D2C8J-H872K-2YT43"

    Write-Host "Setting KMS server..."
    cscript.exe $env:SystemRoot\System32\slmgr.vbs -skms "158.101.213.238"

    Write-Host "Activating Windows..."
    cscript.exe $env:SystemRoot\System32\slmgr.vbs -ato

    Write-Host "Displaying license information..."
    cscript.exe $env:SystemRoot\System32\slmgr.vbs -dlv

    Write-Host "Activation process completed."
}
catch {
    Write-Error "An error occurred: $_"
}