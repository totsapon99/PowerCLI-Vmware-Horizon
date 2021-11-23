# Create by Ivo Beerens
# Date: November 2021

$vcenterserver = " "
Connect-VIServer  $vcenterserver

$allhosts = Get-VMHost | where {$_.ConnectionState -eq "Connected"}

$result = @()
foreach ($allhost in $allhosts) {
    $esxcli = Get-EsxCli -V2 -VMHost $allhost
    $result += $esxcli.storage.core.device.list.invoke() | Where {$_.IsBootDevice -match "true"} | Select @{N="VMhost";e={$allhost.Name}}, Vendor, Model, IsBootDevice, IsLocal, IsSAS, IsSSD, IsUSB, Device 
  
}

$result | FT
