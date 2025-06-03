# File: terraform/modules/aad/variables.tf

variable "name_prefix" {
  description = "Lower-case prefix used in naming AAD resources (e.g., 'collettehealthprod')"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., 'prod')"
  type        = string
}

variable "initial_admins" {
  description = "List of Azure AD Object IDs for users who should be in the 'Admins' group"
  type        = list(string)
}

variable "tenant_id" {
  description = "Azure AD Tenant ID (used by AzureAD provider)"
  type        = string
}
