

locals {
  monitorGroupName                = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "monitor", var.environment, "rg")
  log_analytics_ws_name           = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "la", var.environment, "ws")
}


resource "azurerm_resource_group" "monitor" {
  name     = local.monitorGroupName
  location = var.location

  tags = {
    environment = var.environment
  }
}


# -
# - Log Analytics Workspace
# -
resource "azurerm_log_analytics_workspace" "wks" {
  name                  = local.log_analytics_ws_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.monitor.name
  sku                   = "PerGB2018" #(Required) Specifies the Sku of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard, Standalone, Unlimited, and PerGB2018 (new Sku as of 2018-04-03).
  retention_in_days     = 90         #(Optional) The workspace data retention in days. Possible values range between 30 and 730.
}

resource "azurerm_log_analytics_solution" "agw" {
  solution_name         = "AzureAppGatewayAnalytics"
  location              = azurerm_resource_group.monitor.location
  resource_group_name   = azurerm_resource_group.monitor.name
  workspace_resource_id = azurerm_log_analytics_workspace.wks.id
  workspace_name        = azurerm_log_analytics_workspace.wks.name

  plan {
    publisher           = "Microsoft"
    product             = "OMSGallery/AzureAppGatewayAnalytics"
  }
}

