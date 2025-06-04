variable "name_prefix" {
  description = "Lowercase prefix used in naming all App Service resources (e.g., 'collettehealthprod')"
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier (e.g., 'prod')"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing Resource Group where App Service resources will be created"
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
  description = "Fully qualified path to the TensorFlow API container image in ACR (e.g., '<myacr>.azurecr.io/tf-api:latest')"
  type        = string
}

variable "plan_tier" {
  description = "App Service Plan tier (Basic vs. Standard). Use 'Basic' for cost savings."
  type        = string
  default     = "Basic"
}

variable "plan_size" {
  description = "App Service Plan size (B1 vs. S1, etc.). Use 'B1' for the Basic tier."
  type        = string
  default     = "B1"
}

variable "plan_capacity" {
  description = "Instance count for the App Service Plan. Lower capacity = lower cost."
  type        = number
  default     = 1
}
