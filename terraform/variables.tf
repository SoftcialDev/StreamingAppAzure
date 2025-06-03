# File: terraform/variables.tf

# ---------------------------------------------------------------------------
# Core variables for production deployment
# ---------------------------------------------------------------------------

variable "subscription_id" {
  description = "Azure Subscription ID where resources will be deployed"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD Tenant ID (used by AzureAD provider)"
  type        = string
}

variable "name_prefix" {
  description = "Lower-case prefix used in naming resources (e.g., 'collettehealthprod')"
  type        = string
}

variable "location" {
  description = "Azure region for resource creation (e.g., 'eastus2')"
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier (e.g., 'prod')"
  type        = string
  default     = "prod"
}

variable "resource_group_name" {
  description = "Name of the main Resource Group"
  type        = string
}

variable "enable_slot" {
  description = "Enable the 'staging' slot for the Admin Web App"
  type        = bool
  default     = false
}

variable "servicebus_sku" {
  description = "SKU for Service Bus Namespace (Basic or Standard)"
  type        = string
  default     = "Standard"
}

variable "cosmos_consistency" {
  description = "Cosmos DB consistency level (Session, Strong, etc.)"
  type        = string
  default     = "Session"
}

variable "acr_sku" {
  description = "SKU for Azure Container Registry (Basic, Standard, Premium)"
  type        = string
  default     = "Premium"
}

variable "aks_system_vm_size" {
  description = "VM size for the AKS system node pool"
  type        = string
  default     = "Standard_B2s"
}

variable "aks_spot_vm_size" {
  description = "VM size for the AKS spot node pool"
  type        = string
  default     = "Standard_D4as_v5"
}

variable "tf_api_image" {
  description = "Full path to the TensorFlow API container image in ACR"
  type        = string
}

variable "livekit_image" {
  description = "Full path to the LiveKit container image in ACR"
  type        = string
}

variable "keyvault_sku" {
  description = "SKU for Key Vault (standard or premium)"
  type        = string
  default     = "standard"
}

variable "initial_admin_principals" {
  description = "List of Azure AD Object IDs that should be members of the Admins group and owners of the App Registration"
  type        = list(string)
}

variable "pipeline_sp_object_id" {
  description = "Object ID of the Service Principal used by CI/CD pipelines needing Key Vault or resource permissions"
  type        = string
  default     = ""
}
