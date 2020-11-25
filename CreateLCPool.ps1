Get-Module -ListAvailable 'VMware.Hv.Helper' | Import-Module
Connect-HVServer -Server <servername> -user <user> -password <password> -domain <domain>

# Variables
$poolname = ' '
$pooldisplayName = ' '
$VMTempName = 'GI-W10-1809-10_replica1'
$VMTempSnap = 'v0.1'
$vmfolder = 'W10-CAD-PROD'
$clusname = 'CL-01'
$datastore = 'datastore2'
$description = 'Windows 10 CAD'
$naming = 'W10-P-{n:fixed=3}'
$ou = 'OU=PROD,OU=VDI,OU=ORG'
$netbios = 'ORG'

#Create Pool
New-HVPool -LinkedClone -PoolName $poolname -PoolDisplayName $pooldisplayName -UserAssignment FLOATING -ParentVM $VMTempName -SnapshotVM $VMTempSnap `
-VmFolder $vmfolder -HostOrCluster $clusname -ResourcePool $clusname -Datastores $datastore -NamingMethod PATTERN -NamingPattern $naming `
-Description $description -NetBiosName $netbios -AdContainer $ou -MaximumCount 5 -EnableProvisioning $true -StopProvisioningOnError $true `
-ProvisioningTime UP_FRONT -defaultDisplayProtocol BLAST -supportedDisplayProtocols BLAST -ReusePreExistingAccount:$true `
-custType QUICK_PREP -PowerPolicy ALWAYS_POWERED_ON -AutomaticLogoffPolicy AFTER -AutomaticLogoffMinutes 240 -TransparentPageSharingScope POD `
-StorageOvercommit UNBOUNDED -UseSeparateDatastoresReplicaAndOSDisks:$false -RedirectWindowsProfile:$false -deleteOrRefreshMachineAfterLogoff DELETE

# Assignment
#New-HVEntitlement -ResourceName $poolname -User 'org.local\office365' -ResourceType Desktop -Type Group
New-HVEntitlement -ResourceName $poolname -User 'org.local\test' -ResourceType Desktop -Type User
