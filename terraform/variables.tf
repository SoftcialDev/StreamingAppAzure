# variables.tf (root module)
# ------------------------------------------------------------------------------
# Global / Common variables used by the root and passed into sub-modules.
# ------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Lowercase prefix used in naming all resources (e.g., 'collettehealthprod')."
  type        = string
}

variable "environment" {
  description = "Deployment environment tag (e.g., 'prod')."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing Resource Group."
  type        = string
}

variable "location" {
  description = "Azure region for resources (e.g., 'eastus2')."
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "Azure AD Tenant ID."
  type        = string
}

###################################################
# Service Bus variables
###################################################

variable "servicebus_sku" {
  description = "SKU for Service Bus Namespace: 'Basic', 'Standard', or 'Premium'."
  type        = string
  default     = "Standard"
}

###################################################
# Cosmos DB variables
###################################################

variable "cosmos_consistency" {
  description = "Consistency level for Cosmos DB SQL API (e.g., 'Session', 'Strong')."
  type        = string
  default     = "Session"
}

###################################################
# ACR variables
###################################################

variable "acr_sku" {
  description = "SKU for Azure Container Registry: 'Basic', 'Standard', or 'Premium'."
  type        = string
  default     = "Basic"
}

###################################################
# AKS variables
###################################################

variable "aks_system_vm_size" {
  description = "VM size for AKS system node pool (e.g., 'Standard_B2s')."
  type        = string
  default     = "Standard_B2s"
}

variable "aks_spot_vm_size" {
  description = "VM size for AKS spot node pool (e.g., 'Standard_D4as_v5')."
  type        = string
  default     = "Standard_D4as_v5"
}

variable "aks_spot_max_count" {
  description = "Maximum number of AKS spot nodes (set to 0 to disable)."
  type        = number
  default     = 0
}

###################################################
# App Service variables
###################################################

variable "enable_slot" {
  description = "Whether to create a staging slot for Admin Web App."
  type        = bool
  default     = false
}

variable "tf_api_image" {
  description = "Docker image path for TensorFlow API (e.g., '<acr>.azurecr.io/tf-api:tag')."
  type        = string
  default     = ""
}

###################################################
# Key Vault variables
###################################################

variable "keyvault_sku" {
  description = "SKU for Key Vault: 'Standard' or 'Premium'."
  type        = string
  default     = "Standard"
}

variable "pipeline_sp_object_id" {
  description = "Object ID of the CI/CD pipeline Service Principal (created in main.tf)."
  type        = string
  default     = ""  # Terraform will override after creation
}

###################################################
# Functions variables
###################################################

variable "servicebus_namespace_id" {
  description = "Resource ID of the Service Bus Namespace (for functions to send messages)."
  type        = string
  default     = ""
}

variable "cosmosdb_account_id" {
  description = "Resource ID of the Cosmos DB account (for functions to read/write)."
  type        = string
  default     = ""
}

variable "keyvault_uri" {
  description = "URI of the Key Vault (e.g., 'https://<vault-name>.vault.azure.net/')."
  type        = string
  default     = ""
}

###################################################
# Storage variables
###################################################

variable "enable_static_website" {
  description = "Enable static website hosting on the primary Storage Account?"
  type        = bool
  default     = false
}
