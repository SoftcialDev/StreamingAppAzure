# ----------------------------------------------------------------------------
# Create App Service Plan (Linux, Basic_B1)
# ----------------------------------------------------------------------------

resource "azurerm_app_service_plan" "asp" {
  name                = "${var.name_prefix}-${var.environment}-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"
  reserved            = true  # Required for Linux

  sku {
    tier     = "Basic"
    size     = "B1"
    capacity = 1
  }

  tags = {
    Environment = var.environment
    Project     = "EmployeeMonitoring"
    CreatedBy   = "terraform"
  }
}
