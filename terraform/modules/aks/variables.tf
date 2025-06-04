variable "name_prefix" {
  description = "Lowercase prefix for the AKS cluster name (e.g., 'collettehealthprod')"
  type        = string
}

variable "location" {
  description = "Azure region for AKS (e.g., 'eastus2')"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing Resource Group for AKS"
  type        = string
}

variable "acr_id" {
  description = "Resource ID of the Azure Container Registry for AKS to pull images"
  type        = string
}

variable "system_vm_size" {
  description = "VM size for the default (system) node pool"
  type        = string
  default     = "Standard_B2s"
}

variable "system_node_count" {
  description = "Number of nodes in the default (system) node pool"
  type        = number
  default     = 1
}

variable "spot_vm_size" {
  description = "VM size for the Spot node pool"
  type        = string
  default     = "Standard_D4as_v5"
}

variable "aks_spot_max_count" {
  description = "Maximum number of Spot nodes in the user node pool"
  type        = number
  default     = 2
}

variable "environment" {
  description = "The environment for the AKS cluster (e.g., dev, staging, prod)"
  type        = string
}

variable "create_role_assignment" {
  description = "Whether to create role assignments for the AKS cluster"
  type        = bool
  default     = true
}