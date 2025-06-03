# File: terraform/modules/acr/variables.tf

variable "name_prefix" {
  description = "Lowercase prefix used in naming the ACR (e.g., 'collettehealthprod')"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., 'prod')"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing Resource Group for ACR"
  type        = string
}

variable "location" {
  description = "Azure region for the ACR (e.g., 'eastus2')"
  type        = string
}

variable "sku" {
  description = "SKU for the Azure Container Registry (Basic, Standard, Premium)"
  type        = string
}

variable "akskubelet_identity_id" {
  description = "The ID of the AKS kubelet identity"
  type        = string
}