

locals {

  apimName              = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "fe", var.environment, "apim")
  publisherName         = "marknic"
  publisherEmail        = "marknic@microsoft.com"

}


resource "azurerm_api_management" "apim" {
  name                = local.apimName
  resource_group_name = azurerm_resource_group.frontend_net.name
  location            = azurerm_resource_group.frontend_net.location
  publisher_name      = local.publisherName
  publisher_email     = local.publisherEmail
  sku_name            = "Developer_1"

  virtual_network_configuration {
    subnet_id         = azurerm_virtual_network.hub.id
  }

  policy {
    xml_content = <<XML
    <policies>
      <inbound />
      <backend />
      <outbound />
      <on-error />
    </policies>
    XML
  }

  tags = {
    environment = var.environment
  }
}


resource "azurerm_api_management_api" "apim_api1" {
  name                = "echo-api"
  resource_group_name = azurerm_resource_group.frontend_net.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Echo API"
  path                = "example"
  protocols           = ["http"]

  import {
    content_format = "swagger-link-json"
    content_value  = "http://mnecho.azurewebsites.net/?format=json"
  }
}

