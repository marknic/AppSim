

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                          = "${local.spokeVnetName}_to_${local.hubVnetName}"
  resource_group_name           = local.spokeVnetGroupName
  virtual_network_name          = local.spokeVnetName
  remote_virtual_network_id     = azurerm_virtual_network.hub.id

  allow_virtual_network_access  = true
  allow_forwarded_traffic       = false
  allow_gateway_transit         = false
  use_remote_gateways           = false
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                          = "${local.hubVnetName}_to_${local.spokeVnetName}"
  resource_group_name           = local.hubVnetGroupName
  virtual_network_name          = local.hubVnetName
  remote_virtual_network_id     = azurerm_virtual_network.spoke.id

  allow_virtual_network_access  = true
  allow_forwarded_traffic       = true
  allow_gateway_transit         = true
  use_remote_gateways           = false
}

