
# since these variables are re-used - a locals block makes this more maintainable
locals {
  frontendGroupName               = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "fe", var.environment, "rg")
  common_name                     = format("%s-%s-%s", var.uniquePrefix, var.projectName, var.environment)

  backend_address_pool_name       = "${local.common_name}-bepool"
  frontend_port_name              = "${local.common_name}-feport"
  frontend_ip_configuration_name  = "${local.common_name}-feip"
  http_setting_name               = "${local.common_name}-be-htst"
  listener_name                   = "${local.common_name}-httplstn"
  request_routing_rule_name       = "${local.common_name}-rqrule"
  redirect_configuration_name     = "${local.common_name}-rdconfig"

  appgw_pip_name                  = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "fe", var.environment, "appgw-pip")
  appgw_pip2_name                  = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "fe", var.environment, "appgw-pip2")
  appgw_name                      = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "fe", var.environment, "appgw")

  echoHost                        = "mnecho.azurewebsites.net"
}


resource "azurerm_resource_group" "frontend_net" {
  name     = local.frontendGroupName
  location = var.location
}


resource "azurerm_public_ip" "appgw_pip" {
  name                = local.appgw_pip_name
  resource_group_name = azurerm_resource_group.frontend_net.name
  location            = azurerm_resource_group.frontend_net.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_public_ip" "appgw_pip2" {
  name                = local.appgw_pip2_name
  resource_group_name = azurerm_resource_group.frontend_net.name
  location            = azurerm_resource_group.frontend_net.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_application_gateway" "app_gw" {
  name                = local.appgw_name
  resource_group_name = azurerm_resource_group.frontend_net.name
  location            = azurerm_resource_group.frontend_net.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = "0"
    max_capacity = "2"
  }

  waf_configuration {
    firewall_mode            = "Prevention"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.1"
    enabled                  = true
    max_request_body_size_kb = "128"
    file_upload_limit_mb     = "128"
  }

  gateway_ip_configuration {
    name      = format("%s-%s-%s-%s-%s", var.uniquePrefix, var.projectName, "fe", var.environment, "ipconfig")
    subnet_id = azurerm_subnet.sub_app_gateway.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    fqdns = [local.echoHost]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "echo_probe"
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  probe {
    host = local.echoHost
    interval = 30
    minimum_servers = 0
    name  = "echo_probe"
    path = "/"
    pick_host_name_from_backend_http_settings = false
    protocol = "Http"
    timeout = 30
    unhealthy_threshold = 3

    match {
      status_code = [
        "200-399"
      ]
    }
  }

  tags = {
    environment = var.environment
  }
}


