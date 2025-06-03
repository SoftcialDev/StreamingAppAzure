variable "name_prefix" {
  description = "Lowercase prefix used in naming all resources (e.g., 'collettehealthprod')"
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier (e.g., 'prod')"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing Resource Group for App Service"
  type        = string
}

variable "location" {
  description = "Azure region for App Service (e.g., 'eastus2')"
  type        = string
}

variable "enable_slot" {
  description = "Whether to create a 'staging' slot for the Admin Web App"
  type        = bool
  default     = false
}

variable "tf_api_image" {
  description = "Full path to the TensorFlow API container image in ACR (e.g., '<acr>.azurecr.io/tf-api:latest')"
  type        = string
}
