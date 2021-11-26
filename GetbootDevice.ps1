<#
.SYNOPSIS
    This script list the boot device for every VMware ESXi host
.DESCRIPTION
    VMware is moving away from the support of SD cards and USB drives as boot media.
    ESXi Boot configuration with only SD card or USB drive, without any persistent device, is deprecated with vSphere 7 Update 3. 
    In future vSphere releases, it will be an unsupported configuration.

    More information:
    https://blogs.vmware.com/vsphere/2021/09/esxi-7-boot-media-consideration-vmware-technical-guidance.html
.NOTES
    Version:        1.0
    Author:         Ivo Beerens
    Creation Date:  2021 November
    Change:         Creation
#>

# Import the PowerCLI module
Import-Module VMware.PowerCLI

# Variables
$datefile = ( get-date ).ToString('yyyy-MM-dd-hhmmss')
$file = New-Item -type file "C:\Temp\bootdevices$datefile.csv"
$vcenterserver = Read-Host "Enter the vCenter server name"

# Connect to the vCenter Server
Connect-VIServer  $vcenterserver

# Get cluster
# $cluster = Get-Cluster | Select Name
$cluster = Get-Cluster | Out-GridView -Title "Select the cluster" -OutputMode Single
$allhosts = $cluster | Get-VMHost | where {$_.ConnectionState -eq "Connected"}

$result = @()

foreach ($allhost in $allhosts) {
    $esxcli = Get-EsxCli -V2 -VMHost $allhost
    $result += $esxcli.storage.core.device.list.invoke() | Where {$_.IsBootDevice -match "true"} | Select @{N="Cluster";E={$cluster.Name}},@{N="VMhost";E={$allhost.Name}}, Vendor, Model, IsBootDevice, IsLocal, IsSAS, IsSSD, IsUSB, Device 
}

# Display the output
$result | FT

# Export the output to a CSV file
$result | Export-Csv $file -NoTypeInformation -Force

# Disconnect the vCenter server session 
Disconnect-VIserver -Confirm:$false
