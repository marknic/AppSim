
# Retrieve the subscription data (ID is used below)
data "azurerm_subscription" "current" {
}


locals {
  appGroupName = format("%s-%s-%s-%s", var.uniquePrefix, var.projectName, var.containers, "rg")

  # Function
  app1Language            = "JS"
  app1ShortName           = "app1"
  app1SupportGroupName    = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, local.app1ShortName, var.environment, "srg")
  app1FullName            = format("%s%s%s%s%s",    var.uniquePrefix, var.projectName, local.app1ShortName, var.environment, "fa")
  app1StorageAcctName     = format("%s%s%s%s%s",    var.uniquePrefix, var.projectName, local.app1ShortName, var.environment, "sa")
  app1AppInsightsName     = format("%s%s-%s-%s-%s",  var.uniquePrefix, var.projectName, local.app1ShortName, var.environment, "ai")
  app1AppServicePlanName  = format("%s%s-%s-%s-%s",  var.uniquePrefix, var.projectName, local.app1ShortName, var.environment, "asp")
  # The value below is used as the name of a tag within the App Insights instance (not the Function).  This connects the Function to the App Insights instance.
  #  If this is not set, you will need to make the connection in the App Insights settings within the Function
  app1AiResourceName = format("hidden-link:/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Web/sites/%s", data.azurerm_subscription.current.subscription_id, local.appGroupName, local.app1FullName)


  # Function
  app2Language            = "JV"
  app2ShortName           = "app2"
  app2SupportGroupName    = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, local.app2ShortName, var.environment, "srg")
  app2FullName            = format("%s%s%s%s%s",    var.uniquePrefix, var.projectName, local.app2ShortName, var.environment, "fa")
  app2StorageAcctName     = format("%s%s%s%s%s",    var.uniquePrefix, var.projectName, local.app2ShortName, var.environment, "sa")
  app2AppInsightsName     = format("%s%s-%s-%s-%s",  var.uniquePrefix, var.projectName, local.app2ShortName, var.environment, "ai")
  app2AppServicePlanName  = format("%s%s-%s-%s-%s",  var.uniquePrefix, var.projectName, local.app2ShortName, var.environment, "asp")
  # The value below is used as the name of a tag within the App Insights instance (not the Function).  This connects the Function to the App Insights instance.
  #  If this is not set, you will need to make the connection in the App Insights settings within the Function
  app2AiResourceName = format("hidden-link:/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Web/sites/%s", data.azurerm_subscription.current.subscription_id, local.appGroupName, local.app2FullName)


  # Web App
  app3Language            = "DN"
  app3ShortName           = "app3"
  app3SupportGroupName    = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, local.app3ShortName, var.environment, "srg")
  app3FullName            = format("%s%s%s%s%s",    var.uniquePrefix, var.projectName, local.app3ShortName, var.environment, "fa")
  app3StorageAcctName     = format("%s%s%s%s%s",    var.uniquePrefix, var.projectName, local.app3ShortName, var.environment, "sa")
  app3AppInsightsName     = format("%s%s-%s-%s-%s",  var.uniquePrefix, var.projectName, local.app3ShortName, var.environment, "ai")
  app3AppServicePlanName  = format("%s%s-%s-%s-%s",  var.uniquePrefix, var.projectName, local.app3ShortName, var.environment, "asp")
  # The value below is used as the name of a tag within the App Insights instance (not the Function).  This connects the Function to the App Insights instance.
  #  If this is not set, you will need to make the connection in the App Insights settings within the Function
  app3AiResourceName = format("hidden-link:/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Web/sites/%s", data.azurerm_subscription.current.subscription_id, local.appGroupName, local.app3FullName)



  appConfigName = format("%s-%s", var.projectName, "ac")

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

# Random ID Generator
resource "random_id" "id" {
	  byte_length = 8
}

# Create the resource groups
resource "azurerm_resource_group" "appsim_rg" {
  name     =  "appsim-rg"
  location =  var.location

  tags = {
      Environment = var.environment
    }
}

resource "azurerm_resource_group" "app1_srg" {
  name     =  local.app1SupportGroupName
  location =  var.location

  tags = {
      Environment = var.environment
    }
}

resource "azurerm_resource_group" "app2_srg" {
  name     =  local.app2SupportGroupName
  location =  var.location

  tags = {
      Environment = var.environment
    }
}

resource "azurerm_resource_group" "app3_srg" {
  name     =  local.app3SupportGroupName
  location =  var.location

  tags = {
      Environment = var.environment
    }
}


# =================================================== #
# ===                app1 - Function              === #
# ===            Language - Node.js               === #
# =================================================== #
# Create the storage account for the Function
resource "azurerm_storage_account" "app1" {
  name                      = local.app1StorageAcctName
  resource_group_name       = azurerm_resource_group.app1_srg.name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"

  tags = {
    Environment = var.environment
  }
}


# Create the App Insights instance for the Function
resource "azurerm_application_insights" "app1" {
  name                = local.app1AppInsightsName
  location            = azurerm_resource_group.appsim_rg.location
  resource_group_name = azurerm_resource_group.appsim_rg.name
  application_type    = "Node.JS"
  sampling_percentage = 100
  disable_ip_masking  = true

  tags = {
    Environment = var.environment
    (local.app1AiResourceName) = "Resource"
  }
}


# The App Service Plan for the Function
resource "azurerm_app_service_plan" "app1" {
  name                = local.app1AppServicePlanName
  location            = azurerm_resource_group.app1_srg.location
  resource_group_name = azurerm_resource_group.app1_srg.name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}


# Create the Function
resource "azurerm_function_app" "app1" {
  name                        = local.app1FullName
  location                    = azurerm_resource_group.appsim_rg.location
  resource_group_name         = azurerm_resource_group.appsim_rg.name
  app_service_plan_id         = azurerm_app_service_plan.app1.id
  storage_account_name        = azurerm_storage_account.app1.name
  storage_account_access_key  = azurerm_storage_account.app1.primary_access_key
  os_type                     = "linux"
  https_only                  = true
  version                     = "~3"

  site_config {
    use_32_bit_worker_process = "false"
  }

  tags = {
    Environment = var.environment
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = ""
    "FUNCTIONS_WORKER_RUNTIME" = "node"
    "WEBSITE_NODE_DEFAULT_VERSION" = "~12"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app1.instrumentation_key
    # This setting below is required for the App Insights connection
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app1.connection_string
    # These two below connect the Function with the File Share in the storage account - Required to operate
    #  the "WEBSITE_CONTENTSHARE" value is arbitrary and the Function will use whatever name you provide
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = azurerm_storage_account.app1.primary_connection_string
    "WEBSITE_CONTENTSHARE" = "funcmgmtshare-${random_id.id.hex}"
  }
}




# =================================================== #
# ===                app2 - Function              === #
# ===            Language - Java               === #
# =================================================== #
# Create the storage account for the Function
resource "azurerm_storage_account" "app2" {
  name                      = local.app2StorageAcctName
  resource_group_name       = azurerm_resource_group.app2_srg.name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"

  tags = {
    Environment = var.environment
  }
}


# Create the App Insights instance for the Function
resource "azurerm_application_insights" "app2" {
  name                = local.app2AppInsightsName
  location            = azurerm_resource_group.appsim_rg.location
  resource_group_name = azurerm_resource_group.appsim_rg.name
  application_type    = "Node.JS"
  sampling_percentage = 100
  disable_ip_masking  = true

  tags = {
    Environment = var.environment
    (local.app2AiResourceName) = "Resource"
  }
}


# The App Service Plan for the Function
resource "azurerm_app_service_plan" "app2" {
  name                = local.app2AppServicePlanName
  location            = azurerm_resource_group.app2_srg.location
  resource_group_name = azurerm_resource_group.app2_srg.name
  kind                = "elastic"
  reserved            = true

  sku {
    tier = "ElasticPremium"
    size = "EP1"
    capacity = 1
  }
}


# Create the Function
resource "azurerm_function_app" "app2" {
  name                        = local.app2FullName
  location                    = azurerm_resource_group.appsim_rg.location
  resource_group_name         = azurerm_resource_group.appsim_rg.name
  app_service_plan_id         = azurerm_app_service_plan.app2.id
  storage_account_name        = azurerm_storage_account.app2.name
  storage_account_access_key  = azurerm_storage_account.app2.primary_access_key
  os_type                     = "linux"
  https_only                  = true
  version                     = "~3"

  site_config {
    use_32_bit_worker_process = "false"
  }

  tags = {
    Environment = var.environment
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = ""
    "FUNCTIONS_WORKER_RUNTIME" = "java"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app2.instrumentation_key
    # This setting below is required for the App Insights connection
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app2.connection_string
    # These two below connect the Function with the File Share in the storage account - Required to operate
    #  the "WEBSITE_CONTENTSHARE" value is arbitrary and the Function will use whatever name you provide
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = azurerm_storage_account.app2.primary_connection_string

    "WEBSITE_CONTENTSHARE" = "funcmgmtshare-${random_id.id.hex}"
  }

  identity {
    type = "SystemAssigned"
  }
}




# resource "azurerm_app_service_plan" "appsim" {
#   name                = local.appServicePlanApp2Name
#   location            = azurerm_resource_group.appsim.location
#   resource_group_name = azurerm_resource_group.appsim.name

#   sku {
#     tier = "Standard"
#     size = "S1"
#   }

#   tags = {
#     Environment = var.environment
#     Description = "App Service for browser and API calls - No Containers"
#   }

# }


# resource "azurerm_app_service" "example" {
#   name                = "example-app-service"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
#   app_service_plan_id = azurerm_app_service_plan.example.id

#   site_config {
#     dotnet_framework_version = "v4.0"
#     scm_type                 = "LocalGit"
#   }

#   app_settings = {
#     "SOME_KEY" = "some-value"
#   }

#   connection_string {
#     name  = "Database"
#     type  = "SQLServer"
#     value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
#   }
# }








# =================================================== #
# ===                  App Config                 === #
# =================================================== #
# App Config
resource "azurerm_app_configuration" "appsim_rg" {
  name                = local.appConfigName
  resource_group_name = azurerm_resource_group.appsim_rg.name
  location            = azurerm_resource_group.appsim_rg.location
  sku                 = "standard"

  tags = {
    Environment = var.environment
    Description = "Configuration data for the App Services and Functions"
  }
}

