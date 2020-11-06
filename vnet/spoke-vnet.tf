
locals {
  spokeVnetGroupName  = format("%s-%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "spoke", "vnet", var.environment, "rg")
  spokeVnetName       = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "spoke", var.environment, "vnet")
}

# # Configure the Azure provider
# terraform {
#   required_providers {
#     azurerm = {
#       source = "hashicorp/azurerm"
#       version = ">= 2.26"
#     }
#   }
# }

# provider "azurerm" {
#   features {}
# }


resource "azurerm_resource_group" "spoke_vnet_rg" {
  name     = local.spokeVnetGroupName
  location = var.location

  tags = {
    environment = var.environment
  }
}

# spoke_vnet_address_space  = ["10.0.16.0/20"]

resource "azurerm_virtual_network" "spoke" {
  depends_on           = [azurerm_resource_group.spoke_vnet_rg, azurerm_route_table.net_route, azurerm_network_security_group.netRules]
  name                = local.spokeVnetName
  location            = azurerm_resource_group.spoke_vnet_rg.location
  resource_group_name = azurerm_resource_group.spoke_vnet_rg.name
  address_space       = var.spoke_vnet_address_space

  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "support" {
  depends_on           = [azurerm_virtual_network.spoke]
  name                 = "support"
  resource_group_name  = azurerm_resource_group.spoke_vnet_rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.0.16.0/24"]

  service_endpoints = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "services" {
  depends_on           = [azurerm_virtual_network.spoke]
  name                  = "services"
  resource_group_name   = azurerm_resource_group.spoke_vnet_rg.name
  virtual_network_name  = azurerm_virtual_network.spoke.name
  address_prefixes      = ["10.0.17.0/24"]

  service_endpoints = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "backend" {
  depends_on           = [azurerm_virtual_network.spoke]
  name                 = "backend"
  resource_group_name  = azurerm_resource_group.spoke_vnet_rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.0.18.0/24"]

  service_endpoints = ["Microsoft.Sql", "Microsoft.KeyVault"]
}


output "spoke" {
  value = azurerm_virtual_network.spoke
}

