<#
    Last Updated by: Ivo Beerens
    Date: Juli, 21, 2021
    Reason: Creation

    ToDo:
    # Need extra check for testing if provisioning is disabled

#>

function Get-Desktopinfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$domain,

    #    [Parameter(Mandatory)]
    #    [string]$url,

        [Parameter(Mandatory)]
        [string]$poolnaam

    )

    # Import PowerCLI module
    Import-Module VMware.PowerCLI

    # $addomain = ' '
    # New-VICredentialStoreItem -Host ' ' -User ' ' -Password ' ' -file 'c:\Scripts\horpwd.xml'
    # $creds = Get-VICredentialStoreItem -file 'D:\Scripts\horpwd.xml'
    # Connect-HVServer -Server $url -user $creds.User -password $creds.Password -Domain $domain

    $creds = Get-VICredentialStoreItem -file 'D:\Scripts\horpwd.xml'
    Connect-HVServer -Server $creds.Host -user $creds.User -password $creds.Password -Domain $domain

    # Get Pool information
    $pools = Get-HVPool
    $myCol = @()
    foreach ($pool in $pools) {
        $poolname = $pool.base.name
        $desktops = Get-hvmachinesummary -pool $poolname
        $row = "" | Select-Object Pool, Status, Agent_Unreachable, Error, Provisioning_Error
        $row.Pool = $Pool.Base.Name
        $row.Status = $pool.desktopsettings.enabled
        $row.Agent_Unreachable = ($desktops | Where-Object {$_.base.basicstate -eq "AGENT_UNREACHABLE"}).count
        $row.Error = ($desktops | Where-Object {$_.base.basicstate -eq "ERROR"}).count
        $row.Provisioning_Error = ($desktops | Where-Object {$_.base.basicstate -eq "PROVISIONING_ERROR"}).count
        $myCol += $row
    }

    $FinalOut = $myCol | Where-Object {$_.Pool -eq $poolnaam -and (([int]$_.Agent_Unreachable -gt 0) -or ([int]$_.Error -gt 0) -or ([int]$_.Provisioning_Error -gt 0) -or $_.Status -eq $false)} | Format-Table -AutoSize

    # Following row is for DEV only
    # $FinalOut = $myCol | Where-Object {$_.Pool -eq $poolnaam} | Format-Table -AutoSize

    # Export pool information to file
    $FinalOut | Out-File $("D:\Scripts\Output\" + $poolnaam + ".txt")
}
