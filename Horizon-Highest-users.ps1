#
# VMware Horizon Display the highest user count and perform a counter reset
# https://github.com/vmware/PowerCLI-Example-Scripts 
# $env:PSModulePath
# Connect to VMware Horizon

# Import Modules
Import-Module -Name VMware.VimAutomation.HorizonView 

# Variables
$hor_server = "vdi.ivobeerens.nl"
$hor_domain = "lab.local"
$date = Get-date -UFormat "%d-%m-%Y"
$file_output = "c:\temp\CCU\horizon-ccu-$date.txt"

Write-Output "", "Connecting to the Horizon Connection Server" 
Connect-HVServer -Server $hor_server -domain $hor_domain

# Horizon API overview
$services1 = $Global:DefaultHVServers.ExtensionData

# Get the highest usage
$getusage = $services1.UsageStatistics.UsageStatistics_GetLicensingCounters()
$totalccu = $getusage.HighestUsage.TotalConcurrentConnections

# Write to file
Write-Output "The highest usage count is: $totalccu" | Out-File $file_output -Force

# Mail
Send-MailMessage -SMTPServer $smtp -To $mailto -From $mailfrom -Subject $subject -body "$date, The highest usage count is: $totalccu"

# Reset Highest Usage Count
$services1.UsageStatistics.UsageStatistics_ResetHighestUsageCount()

# Disconnect
Disconnect-HVServer -Server * -Force -Confirm:$false