# ----------------------------------------------------------------------------
# 1. Create Azure Container Registry
# ----------------------------------------------------------------------------
resource "azurerm_container_registry" "acr" {
  name                     = "${var.name_prefix}${var.environment}acr"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.sku
  admin_enabled            = false   # Disable the admin user account


  tags = {
    Environment = var.environment
    CreatedBy   = "terraform"
    Project     = "EmployeeMonitoring"
  }
}

# ----------------------------------------------------------------------------
# 2. Assign Azure RBAC roles so that AKS can pull images
# ----------------------------------------------------------------------------
# Note: AKS module output “aks_kubelet_identity_id” must be passed here
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"                     
  principal_id         = var.akskubelet_identity_id   # Must be passed from AKS module
}
