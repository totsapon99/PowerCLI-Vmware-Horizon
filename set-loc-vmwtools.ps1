# Import PowerCLI module
Import-Module VMware.PowerCLI

# VMware VirtualCenter server name 
$VCserver = read-host "Enter the vCenter server name"

# Connect to the vCenter server 
Connect-VIServer -server $VCserver

$cluster = 'CL-MGNT'
$hosts = Get-Cluster -Name $cluster | Get-VMHost
$datastore = '/vmfs/volumes/nfs01/vmwtools/11.3.0-18090558/'

# Display current VMware Location
$hosts | Get-AdvancedSetting -Name "UserVars.ProductLockerLocation" | Select-Object Entity,Value

# Change VMware Tools location 
Get-cluster -name $cluster | Get-VMhost | %{$_.ExtensionData.UpdateProductLockerLocation($datastore)}  

# Display current VMware Location
$hosts | Get-AdvancedSetting -Name "UserVars.ProductLockerLocation" | Select-Object Entity,Value

# Disconnect vCenter 
Disconnect-VIserver -server * -Confirm:$false
