Login-AzureRmAccount

# Get Resource Name and Storage Account
$RsrcGrp = Get-AzureRmResourceGroup -Name 'ARM-Rsrc-0'

# Get a specific Storage Account
$storeAcct = Get-AzureRmStorageAccount -ResourceGroupName $RsrcGrp.ResourceGroupName | where {$_.StorageAccountName.Equals('armstore0')}

# Get a specific blob in the storage account
$container = "vhd-sp2016"
$storeAcct | Get-AzureStorageBlob -Container $container | where {$_.Name.Endswith('.jpg')} | select name



## Examples Creating Storage Accounts and Containers
## -------------------------------------------------

# Create a new Blob Storage Account for storing infrequently accessed files
$armstore1 = New-AzureRmStorageAccount -ResourceGroupName $RsrcGrp.ResourceGroupName -Name 'armstores6d5f4g' -SkuName Standard_LRS -Location 'westus2' -Kind BlobStorage -AccessTier Cool

    # Create a container for VHDs
    $vhdContainer = New-AzureStorageContainer -Name 'vhd' -Context $armstore1.Context -Verbose -Permission Blob
    get-command '*container*'

AzCopy /Source:https://armstore0.blob.core.windows.net/vhd-sp2016 /Dest:https://armstores6d5f4g.blob.core.windows.net/vhd /SourceKey:c0KHlnwJaAFyRLX+A8vrPS8f1kvBf2AbsfIYhkF4PO1d7rJq4FQpMXHaBPqOH1BUxiyEi67du3b0o4jve7WNiQ== /DestKey:/xZz/3mN7A2KHeS8JDLyQGxKGxOwtTrFfvN3sOw7vw5MpVhPdxT7yenerogDG68vUiu8+km+sz0sd7C/0LhQHQ== /Pattern:SP-SvrImage20169174136.vhd



# Create a new Standard (general) Storage Account for storing frequently access files
$armstore2 = New-AzureRmStorageAccount -ResourceGroupName $RsrcGrp.ResourceGroupName -Name 'armstoresh2kl34' -SkuName Standard_LRS -Location 'westus' -Kind Storage 

    # Create a container for VHDs
    $vhdContainer2 = New-AzureStorageContainer -Name 'vhd' -Context $armstore2.Context -Verbose -Permission Blob

AzCopy /Source:https://armstore0.blob.core.windows.net/vhd-sp2016 /Dest:https://armstoresh2kl34.blob.core.windows.net:443/vhd /SourceKey:c0KHlnwJaAFyRLX+A8vrPS8f1kvBf2AbsfIYhkF4PO1d7rJq4FQpMXHaBPqOH1BUxiyEi67du3b0o4jve7WNiQ== /DestKey:wLCXWPGCsJAS+cmnjiM6MFmIlen8ZvhHoLBPR+I4o7/b4y6GOGQbtdpyKTzUk+ieMRHo1H3n0gFxSYHN+gtsTQ== /Pattern:SP-SvrImage20169174136.vhd


# Add Azure VM Image
Add-AzureVMImage -ImageName 'TMTechSp16Image' -MediaLocation 'https://armstoresh2kl34.blob.core.windows.net/vhd/SP-SvrImage20169174136.vhd' -OS Windows -Description 'Windows Server 2012 R2 loaded with SharePoint 2016 and other convenience tools' 

$blog = ''
$sasToken =   '?sv=2015-04-05&ss=bf&srt=o&sp=r&se=2020-10-25T06:00:00Z&st=2016-10-24T06:00:00Z&spr=https&sig=D0jzznbnXQ0%2B%2B7lNAEHhyxR4rFmrPHdSC42JtL%2BQ798%3D'
$sasBlobUrl = 'https://armstore0.blob.core.windows.net/?sv=2015-04-05&ss=bf&srt=o&sp=r&se=2020-10-25T06:00:00Z&st=2016-10-24T06:00:00Z&spr=https&sig=D0jzznbnXQ0%2B%2B7lNAEHhyxR4rFmrPHdSC42JtL%2BQ798%3D'
$sasFileUrl = 'https://armstore0.file.core.windows.net/?sv=2015-04-05&ss=bf&srt=o&sp=r&se=2020-10-25T06:00:00Z&st=2016-10-24T06:00:00Z&spr=https&sig=D0jzznbnXQ0%2B%2B7lNAEHhyxR4rFmrPHdSC42JtL%2BQ798%3D'


Get-Command -Module AzureRM.Storage -ParameterName *storage*




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
