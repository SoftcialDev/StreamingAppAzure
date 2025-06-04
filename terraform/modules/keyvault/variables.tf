# modules/keyvault/variables.tf
# ------------------------------------------------------------------------------
# Variables for the Key Vault module
# ------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Lowercase prefix used when naming the Key Vault (e.g., 'collettehealthprod')."
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier (e.g., 'prod')."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing Resource Group where the Key Vault will be created."
  type        = string
}

variable "location" {
  description = "Azure region for the Key Vault (e.g., 'eastus2')."
  type        = string
}

variable "sku" {
  description = "SKU for Key Vault: 'standard' or 'premium'. Default is 'standard'."
  type        = string
  default     = "standard"
}

variable "pipeline_sp_object_id" {
  description = "Object ID of the Service Principal used by CI/CD pipelines for Key Vault access. Leave empty if not used."
  type        = string
  default     = ""
}