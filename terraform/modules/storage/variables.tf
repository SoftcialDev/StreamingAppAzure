variable "name_prefix" {
  description = "Lowercase prefix used in naming Storage resources (e.g., 'collettehealthprod')"
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier (e.g., 'prod')"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing Resource Group for Storage"
  type        = string
}

variable "location" {
  description = "Azure region for the Storage Account (e.g., 'eastus2')"
  type        = string
}

variable "enable_static_website" {
  description = "Whether to enable static website hosting on the Storage Account"
  type        = bool
  default     = false
}
