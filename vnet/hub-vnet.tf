
locals {
  hubVnetGroupName = format("%s-%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "hub", "vnet", var.environment, "rg")
  hubVnetName   = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "hub", var.environment, "vnet")
}


# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "hub_vnet_rg" {
  name     = local.hubVnetGroupName
  location = var.location

  tags = {
    environment = var.environment
  }
}


# hub_vnet_address_space    = ["10.0.0.0/20"]

resource "azurerm_virtual_network" "hub" {
  depends_on           = [azurerm_resource_group.hub_vnet_rg]
  name                = local.hubVnetName
  location            = azurerm_resource_group.hub_vnet_rg.location
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name
  address_space       = var.hub_vnet_address_space

  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "sub_hub_mgmt" {
  depends_on           = [azurerm_virtual_network.hub]
  name                 = "support"
  resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.0/25"]

  service_endpoints = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "sub_app_gateway" {
  depends_on           = [azurerm_virtual_network.hub]
  name                  = "app_gateway"
  resource_group_name   = azurerm_resource_group.hub_vnet_rg.name
  virtual_network_name  = azurerm_virtual_network.hub.name
  address_prefixes      = ["10.0.0.128/26"]

  service_endpoints = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "sub_apim" {
  depends_on           = [azurerm_virtual_network.hub]
  name                  = "api_mgmt"
  resource_group_name   = azurerm_resource_group.hub_vnet_rg.name
  virtual_network_name  = azurerm_virtual_network.hub.name
  address_prefixes      = ["10.0.0.192/26"]

  service_endpoints = ["Microsoft.KeyVault"]
}

output "hub" {
  value = azurerm_virtual_network.hub
}

