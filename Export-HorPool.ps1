<#
.SYNOPSIS
    Export-Horizon-pool.ps1
.VERSION
    1.0
.DESCRIPTION
    Exports all the pools on a Horizon Connection Server and saves this in a separate JSON file
.NOTES
    Author(s): Ivo Beerens

    Requirements:  
    Make sure the VMware.HV.Helper module is installed, see: https://github.com/vmware/PowerCLI-Example-Scripts
    Copy the VMware.Hv.Helper to the module location.
.EXAMPLE
    PS> ./Export-Horizon-pool.ps1
#>

#Import PowerCLI module
Import-Module VMware.PowerCLI

#Login variables
$horizonServer = Read-Host -Prompt 'Enter the Horizon Connection Server Name'
$username = Read-Host -Prompt 'Enter the Username (without the domain name)'
$password = Read-Host -Prompt 'Enter the Password' -AsSecureString
$domain = Read-Host -Prompt 'Enter the Horizon AD Domain'
#File location variable
$fileloc = 'C:\Temp'

#Connect to the Horizon Environment
Write-Output "", "Connect to the Connection Server" 
Connect-HVServer -Server $horizonServer -Domain $domain -user $username -Password $password

#Export Horizon pool information to separate json file
Write-Output "", "Connection Server pool export"
$pools = (Get-HVPool).base.name

Write-Host 'Exporting these pools to json',$pools -ForegroundColor Green
ForEach ($pool in $pools) {
    Write-Host ''
    Write-Host 'Export pool',$pool -ForegroundColor green
    Write-Host ''
    Get-hvpool -PoolName $pool | Get-HVPoolSpec -FilePath $fileloc\$pool.json
}