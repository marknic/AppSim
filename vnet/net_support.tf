locals {
  netSupportGroupName  = format("%s-%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "net", "support", var.environment, "rg")
}


resource "azurerm_resource_group" "net_support_rg" {
  name     = local.netSupportGroupName
  location = var.location

  tags = {
    environment = var.environment
  }
}


resource "azurerm_route_table" "net_route" {
  name                          = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "net", var.environment, "route")
  location                      = var.location
  resource_group_name           = azurerm_resource_group.net_support_rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "route-to-internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = {
    environment = var.environment
  }
}


resource "azurerm_network_security_group" "netRules" {
  name                = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "net", var.environment, "nsg")
  location            = var.location
  resource_group_name = azurerm_resource_group.net_support_rg.name

  tags = {
    environment = var.environment
  }
}


resource "azurerm_network_security_rule" "in100" {
  name                        = "Inbound-management"
  direction                   = "Inbound"
  priority                    = "100"
  source_address_prefix       = "AppServiceManagement"
  source_port_range           = "*"
  protocol                    = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "454-455"
  access                      = "Allow"

  resource_group_name         = azurerm_resource_group.net_support_rg.name
  network_security_group_name = azurerm_network_security_group.netRules.name
}

resource "azurerm_network_security_rule" "in110" {
  name                        = "Inbound-load-balancer-keep-alive"
  direction                   = "Inbound"
  priority                    = "110"
  source_address_prefix       = "AzureLoadBalancer"
  source_port_range           = "*"
  protocol                    = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "16001"
  access                      = "Allow"

  resource_group_name         = azurerm_resource_group.net_support_rg.name
  network_security_group_name = azurerm_network_security_group.netRules.name
}


resource "azurerm_network_security_rule" "in120" {
  name                        = "Inbound-HTTP"
  direction                   = "Inbound"
  priority                    = "120"
  source_address_prefix       = "*"
  source_port_range           = "*"
  protocol                    = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "80"
  access                      = "Allow"

  resource_group_name         = azurerm_resource_group.net_support_rg.name
  network_security_group_name = azurerm_network_security_group.netRules.name
}


resource "azurerm_network_security_rule" "in130" {
  name                        = "Inbound-HTTPS"
  direction                   = "Inbound"
  priority                    = "130"
  source_address_prefix       = "*"
  source_port_range           = "*"
  protocol                    = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
  access                      = "Allow"

  resource_group_name         = azurerm_resource_group.net_support_rg.name
  network_security_group_name = azurerm_network_security_group.netRules.name
}


resource "azurerm_network_security_rule" "in140" {
  name                        = "Inbound-FTP"
  direction                   = "Inbound"
  priority                    = "140"
  source_address_prefix       = "*"
  source_port_range           = "*"
  protocol                    = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "21"
  access                      = "Allow"

  resource_group_name         = azurerm_resource_group.net_support_rg.name
  network_security_group_name = azurerm_network_security_group.netRules.name
}


resource "azurerm_network_security_rule" "in150" {
  name                        = "Inbound-FTPS"
  direction                   = "Inbound"
  priority                    = "150"
  source_address_prefix       = "*"
  source_port_range           = "*"
  protocol                    = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "990"
  access                      = "Allow"

  resource_group_name         = azurerm_resource_group.net_support_rg.name
  network_security_group_name = azurerm_network_security_group.netRules.name
}


resource "azurerm_network_security_rule" "in160" {
  name                        = "Inbound-FTP-Data"
  direction                   = "Inbound"
  priority                    = "160"
  source_address_prefix       = "*"
  source_port_range           = "*"
  protocol                    = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "10001-10020"
  access                      = "Allow"

  resource_group_name         = azurerm_resource_group.net_support_rg.name
  network_security_group_name = azurerm_network_security_group.netRules.name
}


resource "azurerm_network_security_rule" "in170" {
  name                        = "Inbound-Remote-Debugging"
  direction                   = "Inbound"
  priority                    = "170"
  source_address_prefix       = "*"
  source_port_range           = "*"
  protocol                    = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "4016-4022"
  access                      = "Allow"

  resource_group_name         = azurerm_resource_group.net_support_rg.name
  network_security_group_name = azurerm_network_security_group.netRules.name
}


resource "azurerm_network_security_rule" "out100" {
  name                        = "Outbound-HTTP"
  direction                   = "Outbound"
  priority                    = "100"
  source_address_prefix       = "*"
  source_port_range           = "*"
  protocol                    = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  access                      = "Allow"

  resource_group_name         = azurerm_resource_group.net_support_rg.name
  network_security_group_name = azurerm_network_security_group.netRules.name
}


resource "azurerm_network_security_rule" "exaout110mple" {
  name                        = "Outbound-HTTPS"
  direction                   = "Outbound"
  priority                    = "110"
  source_address_prefix       = "*"
  source_port_range           = "*"
  protocol                    = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
  access                      = "Allow"

  resource_group_name         = azurerm_resource_group.net_support_rg.name
  network_security_group_name = azurerm_network_security_group.netRules.name
}


resource "azurerm_network_security_rule" "out120" {
  name                        = "Outbound-DNS"
  direction                   = "Outbound"
  priority                    = "120"
  source_address_prefix       = "*"
  source_port_range           = "*"
  protocol                    = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "53"
  access                      = "Allow"

  resource_group_name         = azurerm_resource_group.net_support_rg.name
  network_security_group_name = azurerm_network_security_group.netRules.name
}


resource "azurerm_network_security_rule" "out130" {
  name                        = "Internal-VNET-Outbound"
  direction                   = "Outbound"
  priority                    = "130"
  source_address_prefix       = "*"
  source_port_range           = "*"
  protocol                    = "*"
  destination_address_prefix  = "10.0.0.0/20"
  destination_port_range      = "*"
  access                      = "Allow"

  resource_group_name         = azurerm_resource_group.net_support_rg.name
  network_security_group_name = azurerm_network_security_group.netRules.name
}


resource "azurerm_network_security_rule" "out140" {
  name                        = "Outbound-SQL"
  direction                   = "Outbound"
  priority                    = "140"
  source_address_prefix       = "*"
  source_port_range           = "*"
  protocol                    = "*"
  destination_address_prefix  = "SQL"
  destination_port_range      = "1433"
  access                      = "Allow"

  resource_group_name         = azurerm_resource_group.net_support_rg.name
  network_security_group_name = azurerm_network_security_group.netRules.name
}


resource "azurerm_network_security_rule" "out150" {
  name                        = "Outbound-NTP"
  direction                   = "Outbound"
  priority                    = "150"
  source_address_prefix       = "*"
  source_port_range           = "*"
  protocol                    = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "123"
  access                      = "Allow"

  resource_group_name         = azurerm_resource_group.net_support_rg.name
  network_security_group_name = azurerm_network_security_group.netRules.name
}


