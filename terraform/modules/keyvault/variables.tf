
variable "name_prefix" {
  description = "Lower-case prefix used in naming Key Vault and related resources (e.g., 'collettehealthprod')"
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier (e.g., 'prod')"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing Resource Group for Key Vault"
  type        = string
}

variable "location" {
  description = "Azure region for the Key Vault (e.g., 'eastus2')"
  type        = string
}

variable "sku" {
  description = "SKU for Key Vault: 'standard' or 'premium'"
  type        = string
  default     = "standard"
}

variable "initial_principals" {
  description = "List of Azure AD Object IDs (users or service principals) granted initial secret permissions"
  type        = list(string)
}

variable "pipeline_sp_object_id" {
  description = "Object ID of the Service Principal used by CI/CD pipelines for Key Vault access"
  type        = string
  default     = ""
}
