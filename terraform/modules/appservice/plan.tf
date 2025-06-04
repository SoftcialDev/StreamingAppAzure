# ----------------------------------------------------------------------------
# Create App Service Plan (Linux)
#
# Cost optimizations:
#  - Use Basic tier (B1) instead of Standard (S1).
#  - Single instance (capacity = 1).
# ----------------------------------------------------------------------------
resource "azurerm_app_service_plan" "asp" {
  name                = "${var.name_prefix}-${var.environment}-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"
  reserved            = true  # Required for Linux workers

  sku {
    tier     = var.plan_tier   
    size     = var.plan_size   
    capacity = var.plan_capacity 
  }

  tags = {
    Environment = var.environment
    Role        = "AppServicePlan"
    CreatedBy   = "terraform"
  }
}