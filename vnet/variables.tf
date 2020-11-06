
variable "location" {
  type = string
  description = "Azure Region"
}

variable "projectName" {
  type = string
}

variable "uniquePrefix" {
  type = string
  description = "Set of characters to help make the resource naming succeed and not collide with existing resources."
}

variable "language" {
  type = string
  description = "Language being used within the service: JS - Node.JS, JV - Java, DN - DotNet, PY - Python"
}

variable "containers" {
  type = string
  description = "Indicates if containers are used in the service: nc - No Containers, ct - Containers"
  default     = "nc"
}

variable "environment" {
  type = string
}

variable "hub_vnet_address_space" {
  description = "List of address spaces for the hub virtual network."
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "spoke_vnet_address_space" {
  description = "List of address spaces for the spoke virtual network."
  type        = list(string)
  default     = ["10.0.0.0/24"]
}
