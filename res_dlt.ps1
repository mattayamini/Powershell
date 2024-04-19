$rgname= “res-01”
$location=”East Us”
$storageName = "uniquestrg123"
$storageType = "Standard_LRS"
$nicname = "nic-01"
$subnet1Name = "snet-01"
$vnetName = "vnet-01"
$vnetAddressPrefix = "10.0.0.0/16"
$vnetSubnetAddressPrefix = "10.0.1.0/24" 
$vmName = "vm-01"
$computerName = "vm-01-comp"
$vmSize = "Standard_DS1_v2"
$osDiskName = "osDisk-01"
$username = "yamini"
$password = ConvertTo-SecureString "Yamini@12345" -AsPlainText -Force

New-AzResourceGroup -Name $rgname -Location $location

$storageacc = New-AzStorageAccount -ResourceGroupName $rgname -Name $storageName -Type $storageType -Location $location

# $pubip = New-AzPublicIpAddress -Name $nicname -ResourceGroupName $rgname -Location $location -AllocationMethod Static

$subnetconfig = New-AzVirtualNetworkSubnetConfig -Name $subnet1Name -AddressPrefix $vnetSubnetAddressPrefix

$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgname -Location $location -AddressPrefix $vnetAddressPrefix -Subnet $subnetconfig

$nic = New-AzNetworkInterface -Name $nicname -ResourceGroupName $rgname -Location $location -SubnetId $vnet.Subnets[0].Id # -PublicIpAddressId $pubip.Id

# $cred = Get-Credential -Message "Enter the username and password for VM admin"
$cred = New-Object System.Management.Automation.PSCredential ($username, $password)

$vm = New-AzVMConfig -VMName $vmName -VMSize $vmSize

$vm = Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName $computerName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

$vm = Set-AzVMSourceImage -VM $vm -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2012-R2-Datacenter" -Version "latest"

$vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id

# $blobPath = "vhds/OsDisk1.vhd"

# $osDiskUri = $storageacc.PrimaryEndpoints.Blob.ToString() + $blobPath

$vm = Set-AzVMOSDisk -VM $vm -Name "myOsDisk" -CreateOption fromImage

New-AzVM -ResourceGroupName $rgname -Location $location -VM $vm

Get-AzVM -ResourceGroupName $rgname



<# deletion of the virtual machine and its nic, OsDisk

Stop-AzVM -ResourceGroupName $rgname -Name "vm-01" -Force

Remove-AzVM -ResourceGroupName $rgname -Name "vm-01" -Force

Get-AzNetworkInterface -ResourceGroupName $rgname -Name "nic-01" | Remove-AzNetworkInterface -Force

$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
$osDiskId = $vm.StorageProfile.OsDisk.ManagedDisk.Id
Remove-AzDisk -ResourceGroupName $resourceGroupName -DiskName (Split-Path $osDiskId -Leaf) -Force

Remove-AzDisk -ResourceGroupName $rgname -DiskName "myOsDisk" -Force
#>