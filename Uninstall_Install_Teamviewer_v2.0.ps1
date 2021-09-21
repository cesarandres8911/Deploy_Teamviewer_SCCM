# Find all apps installed on this machine.
$AllApps = Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"

# Find the one named TeamViewer.
$TeamViewer = $AllApps | Where-Object {$_.DisplayName -Like "TeamViewer*"}

# Defines the previous versions of teamviewer to remove. For example, if you define version 15, only versions older than this will be uninstalled.
$oldTwVersion = 15

function stopTeamViewer
{
    # Stop TeamViewer process and service.
    Stop-Process -ID $process.Id -Force
    Wait-Process -ID $process.Id
}

 function uninstallTeamviewer
 {
    # Uninstall TeamViewer
    Start-Process -FilePath ($TeamViewer.UninstallString) -ArgumentList "/S" -Wait -WindowStyle Hidden
    $TeamViewer = $AllApps | Where-Object {$_.DisplayName -Like "TeamViewer*"}
}

function installTeamviewer
{
    # Path to the TeamViewer installer.
    $FILEPATH = '\\Server_ip_Address\Folder\Host\'

    # API key for the TeamViewer installer (Admin teamviewer Cloud deployment). The next is a sample api key.
    $API= '12345678-DkdieCmADfEickasdfe'

    # Config id for the TeamViewer installer (id for deployment package). The next is a sample CONFIGID.
    $CONFIG = '8kieurer'

    # Install the teamviewer msi associated with the API key, config id, and filepath.
    msiexec.exe /i $FILEPATH"TeamViewer_Host.msi" /qb CUSTOMCONFIGID=$CONFIG APITOKEN=$API SETTINGSFILE=$FILEPATH"settingsfile.tvopt" ASSIGNMENTOPTIONS="--reassign"    
}

# Uninstall versions lower than $oldTwVersion.
if ($TeamViewer.VersionMajor -lt $oldTwVersion -And $null -ne $TeamViewer)
{
    # Get all processes in running state
    $processArray = Get-Process
    foreach ($process in $processArray)
    {
        if ($process.ProcessName -Like "TeamViewer*")
        {
            # Get admin rights to kill process.
            if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
            {
                Start-Process PowerShell -WindowStyle Hidden -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
                exit;
            }
            # Stop TeamViewer process and service.
            stopTeamViewer
        }
    }
    # Uninstall old version and install the latest TeamViewer version.
    uninstallTeamviewer
    Start-Sleep -Seconds 15
    installTeamviewer
}

# If there is no teamviewer version installed, install the latest version.
if ($null -eq $TeamViewer)
{
    installTeamviewer
}
