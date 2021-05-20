Function Get-GPUProfile {
    Param ($vmhost)
    $VMhost = Get-VMhost $VMhost
    $vmhost.ExtensionData.Config.SharedPassthruGpuTypes
}
  
Function Get-vGPUDevice {
    Param ($vm)
    $VM = Get-VM $VMTempName
    $vGPUDevice = $VM.ExtensionData.Config.hardware.Device | Where { $_.backing.vgpu}
    $vGPUDevice | Select Key, ControllerKey, Unitnumber, @{Name="Device";Expression={$_.DeviceInfo.Label}}, @{Name="Summary";Expression={$_.DeviceInfo.Summary}}
}
  
Function New-vGPU {
    Param ($VM, $vGPUProfile)
    $VM = Get-VM $VMTempName
    $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
    $spec.deviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec[] (1)
    $spec.deviceChange[0] = New-Object VMware.Vim.VirtualDeviceConfigSpec
    $spec.deviceChange[0].operation = 'add'
    $spec.deviceChange[0].device = New-Object VMware.Vim.VirtualPCIPassthrough
    $spec.deviceChange[0].device.deviceInfo = New-Object VMware.Vim.Description
    $spec.deviceChange[0].device.deviceInfo.summary = ''
    $spec.deviceChange[0].device.deviceInfo.label = 'New PCI device'
    $spec.deviceChange[0].device.backing = New-Object VMware.Vim.VirtualPCIPassthroughVmiopBackingInfo
    $spec.deviceChange[0].device.backing.vgpu = "$vGPUProfile"
    $vmobj = $VM | Get-View
    $reconfig = $vmobj.ReconfigVM_Task($spec)
    if ($reconfig) {
        $ChangedVM = Get-VM $VM
        $vGPUDevice = $ChangedVM.ExtensionData.Config.hardware.Device | Where { $_.backing.vgpu}
        $vGPUDevice | Select Key, ControllerKey, Unitnumber, @{Name="Device";Expression={$_.DeviceInfo.Label}}, @{Name="Summary";Expression={$_.DeviceInfo.Summary}}
  
    }   
}

Function Set-GPU {
   Import-Module VMware.PowerCLI
   $VMhost = 'VM-Host'
   Connect-VIServer -Server $vc_server -User $vc_username -Password $vc_password
    
    $vGPUProfile = Get-GPUProfile -vmhost $VMHost
      
    Write-Host "The following vGPU Profiles are available to choose for this host"
    $vGPUProfile
      
    # Choose a profile to use from the list
    # $ChosenvGPUProfile = $vGPUProfile | Where {$_ -eq "grid_m60-4q" }
	  $ChosenvGPUProfile = $vGPUProfile | Where {$_ -eq "grid_t4-1q"}
	
    Write-Host "Adding the vGPU $ChosenvGPUProfile to $VMTempName"
    New-vGPU -VM $VMTempName -vGPUProfile $ChosenvGPUProfile
      # Disconnect from vCenter
    Disconnect-VIServer -Server * -Confirm:$false
}
