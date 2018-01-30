# Azure

#此目录下将会有一些使用Azure的Powershell脚本

#其中涉及的有IaaS，PaaS等服务

#登陆ARM认证
$Ps=ConvertTo-SecureString -String "******" -AsPlainText -force

$cred= New-Object System.Management.Automation.PSCredential("****.partner.onmschina.cn",$Ps)

Login-AzureRmAccount -EnvironmentName 

$SubName = "Windows Azure 企业"

Select-AzureSubscription -SubscriptionName $SubName
