
# Get the server that has already had sysprep executed on it
#    ans set the status to 'Generalized'
$SvrImageName = 'SP-SvrImage'
$VMRsrcGrp = Get-AzureRmResourceGroup -Name 'VM-ImageBuilds'
Stop-AzureRmVM -ResourceGroupName $VMRsrcGrp.ResourceGroupName -Name $SvrImageName -Confirm:$false 
Set-AzureRmVm -ResourceGroupName $VMRsrcGrp.ResourceGroupName -Name $SvrImageName -Generalized

# Get Reference to the VM Server & set status to generalized
#
$vmImage = Get-AzureRmVM -ResourceGroupName $VMRsrcGrp.ResourceGroupName -Name $SvrImageName -Status
$vmImage.Statuses  # Expecting Code : OSState/generalized


# Save the Image & output the json
# Creates new container in the storage account where the VM's VHD file is located.
#     The new container name is called 'system' and copies the VM image into it
#
#     Example:
#        https://vmimagebuildsdisks63355.blob.core.windows.net/system/Microsoft.Compute/Images/vhd-sp2016/SP16Server-osDisk.ef2f4861-8e0f-4d65-b960-600b54382eaa.vhd
#
Save-AzureRmVMImage -ResourceGroupName $VMRsrcGrp.ResourceGroupName -Name $SvrImageName `
    -DestinationContainerName vhd-sp2016 -VHDNamePrefix SP16Server `
    -Path ('C:\temp\vhd\' + $SvrImageName + '.json')

