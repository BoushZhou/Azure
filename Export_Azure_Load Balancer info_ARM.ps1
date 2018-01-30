$Path = "C:\Users\izero\Documents\testvmlist.csv"
$Result=@()
$AllRG= Get-AzureRmResourceGroup
Foreach($RG in $AllRG){
$LB=Get-AzureRmResource -ResourceType “Microsoft.Network/loadBalancers” -ResourceGroupName $RG.ResourceGroupName 
foreach($lbname in $LB){
$lb=Get-AzureRmLoadBalancer -Name $lbname.Name  -ResourceGroupName $RG.ResourceGroupName 
$FrotendPrivateIp=$lb.FrontendIpConfigurations.PrivateIpAddress
#Frotend IP Pool in the Resouce LB#
if($FrotendPrivateIp -eq $null){
#PLB Scripte in Azure#
$FrotendPrivateIp= "-"
$FrotendPrivateIpMethod= "-"
$lb.FrontendIpConfigurations.PublicIpAddress.id
$pip= Get-AzureRmResource -ResourceId $lb.FrontendIpConfigurations.PublicIpAddress.id
$FrotendPublicIp=$pip.Properties.ipAddress
$FrotendPublicIpMethod=$pip.Properties.publicIPAllocationMethod
}elseif($pip.Properties.ipAddress -ne $null){
#ILB Script in Azure#
$FrotendPrivateIp=$lb.FrontendIpConfigurations.PrivateIpAddress
$FrotendPrivateIpMethod=$lb.FrontendIpConfigurations.PrivateIpAllocationMethod
$FrotendPublicIp="-"
$FrotendPublicIpMethod="-"
  }
# Backend IP Pool in the Resouce #
$tlb=$lb.BackendAddressPools.BackendIpConfigurations.id 
foreach($lbid in $tlb){
 
$nic= Get-AzureRmNetworkInterface -Name $lbid.Split("/")[-3]  -ResourceGroupName $lbid.Split("/")[4]
$VirtualMachine = $nic.VirtualMachine.Id.Split("/")[-1]
$PrivateIpAddress=$nic.IpConfigurations.PrivateIpAddress 
$PrivateIpVersion=$nic.IpConfigurations.PrivateIpAddressVersion  
$PrivateIpMethod=$nic.IpConfigurations.PrivateIpAllocationMethod

$vip=Get-AzureRmResource -ResourceId $nic.Id
$MacAddress= $vip.Properties.macAddress
      $lbObject = New-Object PSObject
                     $lbObject | Add-Member -MemberType NoteProperty -Name "LBName" -Value $lbname.Name
                     $lbObject | Add-Member -MemberType NoteProperty -Name "FrotendPrivateIp" -Value $FrotendPrivateIp
                     $lbObject | Add-Member -MemberType NoteProperty -Name "FrotendPrivateIpMethod" -Value $FrotendPrivateIpMethod
                     $lbObject | Add-Member -MemberType NoteProperty -Name "FrotendPublicIp" -Value $FrotendPublicIp
                     $lbObject | Add-Member -MemberType NoteProperty -Name "FrotendPublicIpMethod" -Value $FrotendPublicIpMethod
                     $lbObject | Add-Member -MemberType NoteProperty -Name "VirtualMachine" -Value $VirtualMachine
                     $lbObject | Add-Member -MemberType NoteProperty -Name "PrivateIpAddress" -Value $PrivateIpAddress
                     $lbObject | Add-Member -MemberType NoteProperty -Name "PrivateIpMethod" -Value $PrivateIpMethod
                     $lbObject | Add-Member -MemberType NoteProperty -Name "PrivateIpVersion" -Value $PrivateIpVersion
                     $lbObject | Add-Member -MemberType NoteProperty -Name "MacAddress " -Value $MacAddress
    $Result+= $lbObject  
    }
  }
}
$Result | Export-Csv $Path -NoTypeInformation -Encoding UTF8