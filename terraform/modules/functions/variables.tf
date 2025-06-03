

variable "name_prefix" {
  description = "Lower-case prefix used in naming Azure resources (e.g., 'collettehealthprod')"
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier (e.g., 'prod')"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing Resource Group for Functions"
  type        = string
}

variable "location" {
  description = "Azure region for the Function resources (e.g., 'eastus2')"
  type        = string
}

variable "servicebus_namespace_id" {
  description = "Resource ID of the Service Bus Namespace (needed to grant Data Sender role)"
  type        = string
}

variable "cosmosdb_account_id" {
  description = "Resource ID of the Cosmos DB account (needed for data contributor role)"
  type        = string
}

variable "keyvault_uri" {
  description = "URI of the Key Vault (needed for granting Key Vault Reader)"
  type        = string
}
