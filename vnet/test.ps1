




Connect-AzAccount


$vnetName = "mn-appsim-hub-dev-vnet"
$resourceGroupName = "mn-appsim-fe-dev-rg"

$subnetAppGatewayName = "app_gateway"

$IpAddress = Get-AzPublicIpAddress -Name "mn-appsim-fe-dev-appgw-pip2" -ResourceGroupName $resourceGroupName


$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName "mn-appsim-hub-vnet-dev-rg" -ErrorAction SilentlyContinue


$appgatewaysubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetAppGatewayName


$AppGw = Get-AzApplicationGateway -Name "mn-appsim-fe-dev-appgw" -ResourceGroupName "mn-appsim-fe-dev-rg"


$fipconfig01 = New-AzApplicationGatewayFrontendIPConfig -Name "api-frontend" -PublicIPAddress $IpAddress

$AppGw = Add-AzApplicationGatewayFrontendIPConfig -ApplicationGateway $AppGw -Name "mn-appsim-dev-feip2" -PublicIPAddress $IpAddress
