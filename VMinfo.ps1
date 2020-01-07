# Import VMware module
Import-Module VMware.VimAutomation.Core

#Login variables
$vcenter = Read-Host -Prompt 'Enter the vCenter Name'
$username = Read-Host -Prompt 'Enter the Username'
$password = Read-Host -Prompt 'Enter the Password' -AsSecureString

# Connect to the VCSA
Connect-VIServer -Server $vcenter -User $username -Password $password

#Variables
$CSVlocation = 'C:\Scripts\Output\vmsvc03.csv'

# VMs
Write-Output "", "Information about VMs"
$VMS = Get-VM
$myCol = @()
ForEach ($VM in $VMS) {
    $row = "" | Select-Object Name, vCenter, 'Cluster Name', VMhost, Folder, Date, Time, 
    PowerState, Boottime, UptimeSec,
    NumCpu, CoresPerSocket, CPUusage, CPUreservation, CPULimit,
    MemoryGB, GuestMemoryUsage, HostMemoryUsage, SharedMemory, SwappedMemory, BalloonedMemory, MemoryReservation, MemoryLimit,
    ProvisionedDiskGB, UsedSpaceGB, TotalHDD, Harddisks, HardiskFormat, TotalNics, TimsSync,
    IPAdress, PortGroup, VMCreated, Template, OS, GuestFullName, ToolsVersion, ToolStatus, Toolsver2, HWversion, ConsolidationNeeded, CTB, Notes
    $row.Name = $VM.name
    $row.PowerState = $VM.PowerState
    $row.vCenter = $Global:defaultviserver.Name
    $row.'Cluster name' = $VM | Get-Cluster | Select-Object -Unique -Expand Name
    $row.VMhost = $VM.VMHost
    $row.Folder = $VM.Folder
    $row.Date = $date
    $row.Time = $Time
    $row.Boottime = $VM.ExtensionData.Summary.Runtime.BootTime
    $row.UptimeSec = $VM.ExtensionData.Summary.QuickStats.UptimeSeconds
    $row.NumCpu = $VM.NumCpu
    $row.CoresPerSocket = $VM.CoresPerSocket
    $row.CPUusage = $VM.ExtensionData.Summary.QuickStats.OverallCpuDemand
    $row.CPUreservation = $VM.ExtensionData.ResourceConfig.CpuAllocation.Reservation
    $row.CPULimit = $VM.ExtensionData.ResourceConfig.CpuAllocation.Limit
    $row.MemoryGB = $VM.MemoryGB
    $row.GuestMemoryUsage = $VM.ExtensionData.Summary.QuickStats.GuestMemoryUsage
    $row.HostMemoryUsage = $VM.ExtensionData.Summary.QuickStats.HostMemoryUsage
    $row.SharedMemory = $VM.ExtensionData.Summary.QuickStats.SharedMemory
    $row.SwappedMemory = $VM.ExtensionData.Summary.QuickStats.SwappedMemory
    $row.BalloonedMemory = $VM.ExtensionData.Summary.QuickStats.BalloonedMemory
    $row.MemoryReservation = $VM.ExtensionData.ResourceConfig.MemoryAllocation.Reservation
    $row.MemoryLimit = $VM.ExtensionData.ResourceConfig.MemoryAllocation.Limit
    $row.ProvisionedDiskGB = ([Math]::Round($VM.ProvisionedSpaceGB, 2))
    $row.UsedSpaceGB = ([Math]::Round($VM.UsedSpaceGB, 2))
    $row.TotalHDD = $VM | Select name, @{N="TotalHDD"; E={($_ | Get-HardDisk).count }}
    $row.Harddisks = $VM | Get-Harddisk | Select-Object Parent, FileName, Name, CapacityGB, Persistence, StorageFormat
    $row.HardiskFormat = $VM | Get-Harddisk | Select-Object -Unique -Expand StorageFormat | Sort-Object StorageFormat
    $row.TotalNics = $VM.ExtensionData.summary.config.numEthernetCards
    $row.TimsSync = $VM.ExtensionData.Config.Tools.SyncTimeWithHost
    $row.IPAdress = $VM | Get-VMGuest | Select-Object -Unique -Expand IPAddress
    $row.PortGroup = $VM | Get-NetworkAdapter | Select-Object -Unique -Expand NetworkName | Sort-Object NetworkName
    $row.VMCreated = $VM.ExtensionData.Config.CreateDate
    $row.Template = $VM.ExtensionData.Config.Template
    $row.OS = $VM.Guest.ExtensionData.GuestFullName
    $row.GuestFullName = $VM.ExtensionData.Config.GuestFullName
    $row.ToolsVersion = $VM.Guest.ToolsVersion
    $row.ToolStatus = $VM.Guest.ExtensionData.ToolsRunningStatus
    $row.Toolsver2 = $VM.Guest.ExtensionData.ToolsVersionStatus2
    $row.HWversion = $VM.HardwareVersion
    $row.ConsolidationNeeded = $VM.ExtensionData.Runtime.ConsolidationNeeded
    $row.CTB = $VM.ExtensionData.Config.ChangeTrackingEnabled
    $row.Notes = $VM.Notes
    $myCol += $row
}

Write-Output $myCol
$mycol | Export-Csv $CSVlocation -NoTypeInformation

Disconnect-VIServer * -Confirm:$false