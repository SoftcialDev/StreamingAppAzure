
variable "name_prefix" {
  description = "Lower-case prefix used in naming Service Bus resources (e.g., 'collettehealthprod')"
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier (e.g., 'prod')"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing Resource Group for Service Bus"
  type        = string
}

variable "location" {
  description = "Azure region for the Service Bus Namespace (e.g., 'eastus2')"
  type        = string
}

variable "sku" {
  description = "SKU for the Service Bus Namespace (Basic or Standard)"
  type        = string
  default     = "Standard"
}
