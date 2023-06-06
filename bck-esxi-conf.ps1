# Backups the configuration of all the VMware ESXi servers connected in the vCenter Server and save it on the local Windows Server.

#Variables
$Folder = "D:\VMware\BCK-ESXi"
$FolderOld = "D:\VMware\BCK-ESXi\_old"
$vc= "vcenter-server-fqdn"

# Connect to local vCenter Server
Connect-ViServer -Server $vc

# Move existing backup files to the old directory
Move-Item ($Folder + "\*.tgz") $FolderOld -force -ErrorAction SilentlyContinue

# Backkup ESXi configuration
Get-VMHost | ForEach-Object {
    $_ | Get-VMHostFirmware -BackupConfiguration -DestinationPath $folder
}

# Disconnect session vCenter 
Disconnect-VIserver -Confirm:$false
