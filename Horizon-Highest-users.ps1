#
# VMware Horizon Display the highest user count and perform a counter reset
# 
# Connect to VMware Horizon
Write-Output "", "Connecting to the Horizon Connection Server" 
Connect-HVServer -Server <server> -user <user> -domain <domain>

# Variables
$date = Get-date -UFormat "%d-%m-%Y"
$output = "c:\Scripts\Output\CCU\horizon-ccu-$date.txt"
$smtp = " "
$mailto = " "
$mailfrom = " "
$subject = " "

# Horizon API overview
$services1 = $Global:DefaultHVServers.ExtensionData

# Get the highest licensing
$getusage = $services1.UsageStatistics.UsageStatistics_GetLicensingCounters()
$totalccu = $getusage.HighestUsage.TotalConcurrentConnections

# Write to file
Write-Output The highest usage count is: $totalccu" | Out-File $output -Force

# Mail
Send-MailMessage -SMTPServer $smtp -To $mailto -From $mailfrom -Subject $subject -body "$date, The highest usage count is: $totalccu"

# Reset Highest Usage Count
$services1.UsageStatistics.UsageStatistics_ResetHighestUsageCount()

# Disconnect
Disconnect-HVServer -Server * -Force -Confirm:$false
