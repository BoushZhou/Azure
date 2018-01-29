#登陆ARM认证
$Ps=ConvertTo-SecureString -String "your pass word" -AsPlainText -force
$cred= New-Object System.Management.Automation.PSCredential("your org id.partner.onmschina.cn",$Ps)
Login-AzureRmAccount -EnvironmentName AzureChinaCloud -Credential $cred
$SubName = "your subscribtion name"
Select-AzureRmSubscription -SubscriptionName $SubName
#导出文件存储路径
$Path = "C:\Users\izero\Documents\testvmlist.csv"
$Result=@()
#列出此订阅下所有的资源组
$AllRG = Get-AzureRmResourceGroup
#检索虚拟机信息存储为PS对象
foreach($RG in $AllRG)
{
#列出RG下所有虚拟机的Name
$allvmname=Get-AzureRmResource -ResourceType "Microsoft.Compute/virtualMachines" -ResourceGroupName $RG.ResourceGroupName 
#if($allvmname.Name -eq $null )
#{ break; }
 foreach($vmname in $allvmname)
        {
         #列出虚拟机的基本属性信息
         $vm=Get-AzureRmVM -ResourceGroupName $RG.ResourceGroupName  -Name $vmname.Name
         Start-Sleep -Seconds 2
         #$vm=Get-AzureRmVM -ResourceGroupName hanssem-prod-rg   -Name prod-api01 
         $vm.OSProfile.LinuxConfiguration
         if($vm.OSProfile.LinuxConfiguration -eq $null)
         {$OS = "Windows" }
           else
                { $OS = "Linux" }
         $Location = $vm.Location
         $VmSize = $vm.HardwareProfile.VmSize
         $DataDisksName = $vm.StorageProfile.DataDisks[0].Name
         $DataDisksCount = $vm.StorageProfile.DataDisks.Count
         #列出虚拟机的可用性集
         if($vm.AvailabilitySetReference.Id -eq $null)
         { $AvailabilitySetName = "-"
                  }
           else
                { $AvailabilitySetName = $vm.AvailabilitySetReference.Id.Split("/")[-1] }
         #列出虚拟机的私有网络信息
         $nic=Get-AzureRmNetworkInterface -Name $vm.NetworkProfile.NetworkInterfaces.Id.Split("/")[-1] -ResourceGroupName $RG.ResourceGroupName 
         #$nic=Get-AzureRmNetworkInterface -Name $vm.NetworkProfile.NetworkInterfaces.Id.Split("/")[-1] -ResourceGroupName hanssem-prod-rg
         Start-Sleep -Seconds 2
         $PrivateIp = $nic.IpConfigurations.PrivateIpAddress
         $PrivateIpVersion = $nic.IpConfigurations.PrivateIpAddressVersion 
         $PrivateIpMethod = $nic.IpConfigurations.PrivateIpAllocationMethod
         $VirtualNetworkName = $nic.IpConfigurations.Subnet.Id.Split("/")[-3]
         $SubnetName = $nic.IpConfigurations.Subnet.Id.Split("/")[-1]
         #列出虚拟机的公共网卡信息
         if($nic.IpConfigurations.PublicIpAddress.Id -eq $null)
         {  $PublicIP = "-"
            $PublicIPMethod = "-" }
           else
                {$pip=Get-AzureRmResource -ResourceId $nic.IpConfigurations.PublicIpAddress.Id
         $PublicIP = $pip.Properties.ipAddress
         $PublicIPMethod = $pip.Properties.publicIPAllocationMethod }
         #列出虚拟机的网络安全组信息
         if($nic.NetworkSecurityGroup.Id -eq $null)
         { $NetworkSecurityGroup = "-"
                  }
           else
                { $NetworkSecurityGroup = $nic.NetworkSecurityGroup.Id.Split("/")[-1] }
        
         #输入到PS对象
         $vmObject = New-Object PSObject
                     $vmObject | Add-Member -MemberType NoteProperty -Name "VMName" -Value $vmname.Name
                     $vmObject | Add-Member -MemberType NoteProperty -Name "Location" -Value $Location
                     $vmObject | Add-Member -MemberType NoteProperty -Name "OS" -Value $OS
                     $vmObject | Add-Member -MemberType NoteProperty -Name "VmSize" -Value $VmSize
                     $vmObject | Add-Member -MemberType NoteProperty -Name "DataDisksName" -Value $DataDisksName
                     $vmObject | Add-Member -MemberType NoteProperty -Name "DisksCount" -Value $DataDisksCount
                     $vmObject | Add-Member -MemberType NoteProperty -Name "AvailabilitySetName" -Value $AvailabilitySetName
                     $vmObject | Add-Member -MemberType NoteProperty -Name "PrivateIp" -Value $PrivateIp
                     $vmObject | Add-Member -MemberType NoteProperty -Name "PrivateIpVersion" -Value $PrivateIpVersion
                     $vmObject | Add-Member -MemberType NoteProperty -Name "PrivateIpMethod " -Value $PrivateIpMethod
                     $vmObject | Add-Member -MemberType NoteProperty -Name "PublicIP" -Value $PublicIP
                     $vmObject | Add-Member -MemberType NoteProperty -Name "PublicIPMethod" -Value $PrivateIpMethod
                     $vmObject | Add-Member -MemberType NoteProperty -Name "NetworkSecurityGroup" -Value $NetworkSecurityGroup
                     $vmObject | Add-Member -MemberType NoteProperty -Name "VirtualNetworkName" -Value $VirtualNetworkName
                     $vmObject | Add-Member -MemberType NoteProperty -Name "SubnetName" -Value $SubnetName
          $Result+= $vmObject  
          Start-Sleep -Seconds 2
         }
}
$Result | Export-Csv $Path -NoTypeInformation -Encoding UTF8
