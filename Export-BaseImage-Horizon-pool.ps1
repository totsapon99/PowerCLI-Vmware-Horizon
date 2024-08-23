<#
.SYNOPSIS
    Export-BaseImage-Horizon-pool.ps1
.VERSION
    1.0
.DESCRIPTION
    Exports BaseImage all the pools on a Horizon Connection Server and saves this in a CSV file
.NOTES
    Author(s): Totsapon Ruangsri

    Requirements:  
    Make sure the VMware.HV.Helper module is installed, see: https://github.com/vmware/PowerCLI-Example-Scripts
    Copy the VMware.Hv.Helper to the module location.
.EXAMPLE
    PS> ./Export-BaseImage-Horizon-pool.ps1
#>

#Import PowerCLI module
Import-Module VMware.Hv.Helper

#Login variables
$horizonServer = Read-Host -Prompt 'Enter the Horizon Connection Server Name'
$username = Read-Host -Prompt 'Enter the Username (without the domain name)'
$password = Read-Host -Prompt 'Enter the Password' -AsSecureString
$domain = Read-Host -Prompt 'Enter the Horizon AD Domain'

#Connect to the Horizon Environment
Write-Host "Connect to the Connection Server" 
Connect-HVServer -Server $horizonServer -Domain $domain -user $username -Password $password

#Export Horizon pool information to separate json file
Write-Host "Get list Pools name" 
$pools = (Get-HVPool).base.name	
Write-Host ''
Write-Host 'Collect Pool Name List : ',$pools -ForegroundColor Green
Write-Host ''

# Initialize an empty array to store all VMs data
$allVmsData = @()

ForEach ($pool in $pools) {
    Write-Host ''
    Write-Host 'Get Data in pool: ' -NoNewline
    Write-Host $pool -ForegroundColor Red
    
    $vms = (Get-HVMachine -poolname $pool).base.name  # Get VDI name
    
    Write-Host 'Start Loop 2'
    $vmsData = ForEach($vm in $vms) {
        $machine = Get-HVMachine -MachineName $vm

        [PSCustomObject]@{
            'Pool Name'                = $pool
            'VDI Name'                 = $vm
            'Base Image Path'          = $machine.ManagedMachineData.ViewComposerData.BaseImagePath
            'Base Image Snapshot Path' = $machine.ManagedMachineData.ViewComposerData.BaseImageSnapshotPath
        }
    }
    
    # Add the current pool's VMs data to the overall data array
    $allVmsData += $vmsData
}

# Specify the file path for the CSV
$outputPath = "D:\GetBaseImageAllVDI.csv"

# Export the accumulated data to a CSV file
$allVmsData | Export-Csv -Path $outputPath -NoTypeInformation

Write-Host "Data saved to $outputPath"
Write-Host "!! Enjoyed !!"




