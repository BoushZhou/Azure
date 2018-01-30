#导出文件存储路径
$path = "D:\zuchevmlist.csv"
$result=@()
#Get All Cloud Service Name
     $AllServiceNames = (Get-AzureService).servicename

     foreach ($ServiceName in $AllServiceNames)
     {
         "Export: " + $ServiceName
             $deploymentId = (Get-AzureDeployment -ServiceName $ServiceName -ErrorAction SilentlyContinue).DeploymentId 

             $deployments = Get-AzureDeployment -ServiceName $ServiceName -Slot Production -ErrorAction SilentlyContinue

             foreach ($InstanceList in $deployments.RoleInstanceList)
             {
              
                  if($InstanceList.InstanceName -like '*_IN_*')
                  {
                     $VMType="Cloud Service";
                    $VMstatu = switch($InstanceList.InstanceStatus){
                        {$_ -eq "StoppedDeallocated"}{"Stopped";break}
                        {$_ -eq "Stopped"}{"System_Stopped";break}
                        {$_ -eq "ReadyRole"}{"Started";break}
                        deafult{$_}
                    }

                    $CSsize = switch($InstanceList.InstanceSize){
                        {$_ -eq "Small"}{"A1(1core 1.75GB)";break}
                        {$_ -eq "Medium"}{"A2(2core 3.5GB)";break}
                        {$_ -eq "Large"}{"A3(4core 7GB)";break}
                        {$_ -eq "Basic_A1"}{"A1_Basic(1core 1.75GB)";break}
                        {$_ -eq "Basic_A2"}{"A2_Basic(2core 3.5GB)";break}
                        {$_ -eq "Basic_A3"}{"A3_Basic(4core 7GB)";break}
                        deafult {$_}
                    }

                     $vmObject = New-Object PSObject
                     #$vmObject | Add-Member -MemberType NoteProperty -Name "SubscriptioName" -Value $sub
     
                     $vmObject | Add-Member -MemberType NoteProperty -Name "ServiceName" -Value $ServiceName
                     $vmObject | Add-Member -MemberType NoteProperty -Name "Type" -Value $VMType 
                     $vmObject | Add-Member -MemberType NoteProperty -Name "InstanceName" -Value $InstanceList.InstanceName
                     $vmObject | Add-Member -MemberType NoteProperty -Name "InstanceSize" -Value $CSsize

                     $vmObject | Add-Member -MemberType NoteProperty -Name "Status" -Value $VMstatu
                     $vmObject | Add-Member -MemberType NoteProperty -Name "AvailabilitySetName" -Value "Auto"
                     $vmObject | Add-Member -MemberType NoteProperty -Name "VIP" -Value $deployments.VirtualIPs[0].Address

                     $result+= $vmObject 
                  }
                  else
                  {
                    $VMType="Virtual Machine";
                    #break;
                    $vm = Get-AzureVM -ServiceName $ServiceName -Name $InstanceList.InstanceName 
                    $endpoints = Get-AzureVM -ServiceName $vm.ServiceName -Name $vm.Name|Get-AzureEndpoint
                    $vip=($endpoints|Select Vip|Sort-Object -Property Vip -Unique)
                    $OSdisk = Get-AzureOSDisk -VM $vm
                    $DATAdisks = Get-AzureDataDisk -VM $vm
                    $DATAdisk = ""
                    foreach($disk in $DATAdisks){
                        $DATAdisk = $DATAdisk + $disk.DiskName + "`n"
                    }
                    $VMstatu = switch($vm.Status){
                        {$_ -eq "StoppedDeallocated"}{"Stopped";break}
                        {$_ -eq "Stopped"}{"System_Stopped";break}
                        {$_ -eq "ReadyRole"}{"Started";break}
                    }

                    $VMsize = switch($vm.InstanceSize){
                        {$_ -eq "ExtraSmall"}{"A0(0core 756MB)";break}
                        {$_ -eq "Small"}{"A1(1core 1.75GB)";break}
                        {$_ -eq "Medium"}{"A2(2core 3.5GB)";break}
                        {$_ -eq "Large"}{"A3(4core 7GB)";break}
                        {$_ -eq "ExtraLarge"}{"A4(8core 14GB)";break}
                        {$_ -eq "A5"}{"A5(2core 14GB)";break}
                        {$_ -eq "A6"}{"A6(4core 28GB)";break}
                        {$_ -eq "A7"}{"A7(8core 56GB)";break}
                        {$_ -eq "Basic_A0"}{"A0_Basic(0core 756MB)";break}
                        {$_ -eq "Basic_A1"}{"A1_Basic(1core 1.75GB)";break}
                        {$_ -eq "Basic_A2"}{"A2_Basic(2core 3.5GB)";break}
                        {$_ -eq "Basic_A3"}{"A3_Basic(4core 7GB)";break}
                        {$_ -eq "Basic_A4"}{"A4_Basic(8core 14GB)";break}
                        {$_ -eq "Standard_D1"}{"D1(1core 3.5GB)";break}
                        {$_ -eq "Standard_D2"}{"D2(2core 7GB)";break}
                        {$_ -eq "Standard_D3"}{"D3(3core 14GB)";break}
                        {$_ -eq "Standard_D4"}{"D4(4core 28GB)";break}
                        {$_ -eq "Standard_D11"}{"D11(2core 14GB)";break}
                        {$_ -eq "Standard_D12"}{"D12(4core 28GB)";break}
                        {$_ -eq "Standard_D13"}{"D13(8core 56GB)";break}
                        {$_ -eq "Standard_D14"}{"D14(16core 112GB)";break}
                    }
                     $vmObject = New-Object PSObject
                     $vmObject | Add-Member -MemberType NoteProperty -Name "ServiceName" -Value $ServiceName
                     $vmObject | Add-Member -MemberType NoteProperty -Name "Type" -Value $VMType
                     $vmObject | Add-Member -MemberType NoteProperty -Name "DNSName" -Value $vm.DNSName
                     $vmObject | Add-Member -MemberType NoteProperty -Name "VMName" -Value $InstanceList.InstanceName
                     $vmObject | Add-Member -MemberType NoteProperty -Name "OS" -Value $OSdisk.OS
                     $vmObject | Add-Member -MemberType NoteProperty -Name "Status" -Value $VMstatu
                     $vmObject | Add-Member -MemberType NoteProperty -Name "DIP" -Value $vm.IpAddress
                     $vmObject | Add-Member -MemberType NoteProperty -Name "PIP" -Value $vm.PublicIPAddress
                     $vmObject | Add-Member -MemberType NoteProperty -Name "PIPName" -Value $vm.PublicIPName
                     $vmObject | Add-Member -MemberType NoteProperty -Name "VIP" -Value $vip.Vip
                     $vmObject | Add-Member -MemberType NoteProperty -Name "InstanceSize" -Value $VMsize
                     $vmObject | Add-Member -MemberType NoteProperty -Name "AvailabilitySetName" -Value $vm.AvailabilitySetName
                     $vmObject | Add-Member -MemberType NoteProperty -Name "network" -Value $vm.VirtualNetworkName
                     $vmObject | Add-Member -MemberType NoteProperty -Name "OSDisk" -Value $OSdisk.DiskName
                     $vmObject | Add-Member -MemberType NoteProperty -Name "DATADisk" -Value $DATAdisk
                     $vmObject | Add-Member -MemberType NoteProperty -Name "StorageAccount" -Value $OSdisk.MediaLink.ToString().Substring(8,$OSdisk.MediaLink.ToString().IndexOf(".") - 8) 

                    $result+= $vmObject  
                  }
             }
     }


$result | Export-Csv $path -NoTypeInformation -Encoding UTF8
