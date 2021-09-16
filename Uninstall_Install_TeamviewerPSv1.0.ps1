# Find all apps installed on this machine.
$AllApps = Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"

# Find the one named TeamViewer.
$TeamViewer = $AllApps | Where-Object {$_.DisplayName -Like "TeamViewer*"}

# Defines the previous versions of teamviewer to remove. For example, if you define version 15, only versions older than this will be uninstalled.
$oldTwVersion = 15 

# Uninstall versions lower than $oldTwVersion.
if ($TeamViewer.DisplayVersion -lt $oldTwVersion -And $null -ne $TeamViewer) {
    # Identify and stop TeamViewer id process
    $twid = (Get-Process TeamViewer).id
    Stop-Process -Id $twid
    Wait-Process -Id $twid

    # Uninstall TeamViewer
    Start-Process -FilePath ($TeamViewer.UninstallString) -ArgumentList "/S" -WindowStyle Hidden
}


# Path to the TeamViewer installer.
$FILEPATH = '\\Server_ip_Address\Folder\Host\'

# API key for the TeamViewer installer (Admin teamviewer Cloud deployment). The next is a sample api key.
$API= '12345678-DkdieCmADfEickasdfe'

# Config id for the TeamViewer installer (id for deployment package). The next is a sample CONFIGID.
$CONFIG = '8kieurer'

# Install the teamviewer msi associated with the API key, config id, and filepath. The settingsfile.tvopt is generated from the host client settings (export setting from any teamviewer client).
 msiexec.exe /i $FILEPATH"TeamViewer_Host.msi" /qb CUSTOMCONFIGID=$CONFIG APITOKEN=$API SETTINGSFILE=$FILEPATH"settingsfile.tvopt" ASSIGNMENTOPTIONS="--reassign"

