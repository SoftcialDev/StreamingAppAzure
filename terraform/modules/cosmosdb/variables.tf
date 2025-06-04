variable "name_prefix" {
  description = "Lowercase prefix used in naming Cosmos resources (e.g., 'collettehealthprod')"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., 'prod')"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing Resource Group for Cosmos DB"
  type        = string
}

variable "location" {
  description = "Azure region for the Cosmos DB account (e.g., 'eastus2')"
  type        = string
}

variable "consistency_level" {
  description = "Desired consistency policy for Cosmos DB (e.g., 'Session', 'Strong')"
  type        = string
  default     = "Session"
}
