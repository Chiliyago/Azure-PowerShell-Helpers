# Get the server that has already had sysprep executed on it
$SvrImageName = 'SP-SvrImage'
$VMRsrcGrp = Get-AzureRmResourceGroup -Name 'VM-ImageBuilds'
Stop-AzureRmVM -ResourceGroupName $VMRsrcGrp.ResourceGroupName -Name $SvrImageName -Confirm:$false 
Set-AzureRmVm -ResourceGroupName $VMRsrcGrp.ResourceGroupName -Name $SvrImageName -Generalized

# Get Reference to the VM Server & set status to generalized
$vmImage = Get-AzureRmVM -ResourceGroupName $VMRsrcGrp.ResourceGroupName -Name $SvrImageName -Status
$vmImage.Statuses  # Expecting Code : OSState/generalized

# Save the Image & output the json
Save-AzureRmVMImage -ResourceGroupName $VMRsrcGrp.ResourceGroupName -Name $SvrImageName `
    -DestinationContainerName vhd-sp2016 -VHDNamePrefix SP16Server `
    -Path ('C:\temp\vhd\' + $SvrImageName + '.json')