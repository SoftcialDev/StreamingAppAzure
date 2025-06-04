###############################################################################
# 1. Create Azure Container Registry (no admin user, cost-optimized SKU)
###############################################################################
resource "azurerm_container_registry" "acr" {
  name                     = "${var.name_prefix}${var.environment}acr"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.sku
  admin_enabled            = false

  tags = {
    Environment = var.environment
    CreatedBy   = "terraform"
    Project     = "EmployeeMonitoring"
  }
}

###############################################################################
# 2. Assign RBAC role so AKS can pull images from this ACR
###############################################################################
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = var.akskubelet_identity_id

  # We ignore changes to principal_id in case the AKS kubelet identity changes later
  lifecycle {
    ignore_changes = [
      principal_id,
    ]
  }
}
