
# ----------------------------------------------------------------------------
# 1. Admin Dashboard Web App (Linux, Node 20 LTS, ZIP deploy)
# ----------------------------------------------------------------------------
resource "azurerm_linux_web_app" "admin" {
  name                = "${var.name_prefix}-${var.environment}-adminwebapp"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_app_service_plan.asp.id

  site_config {
    always_on  = true
    ftps_state = "Disabled"
    # No need to set linux_fx_version here: Terraform will inherit from 
    # the published artifact (run‐from‐package).
  }

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  tags = {
    Environment = var.environment
    Role        = "AdminDashboard"
    CreatedBy   = "terraform"
  }
}

# ----------------------------------------------------------------------------
# 2. Optional Staging Slot for Admin Web App
# ----------------------------------------------------------------------------
resource "azurerm_app_service_slot" "admin_staging" {
  count               = var.enable_slot ? 1 : 0
  name                = "staging"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.asp.id
  app_service_name    = azurerm_linux_web_app.admin.name

  site_config {
    linux_fx_version = "Node|20"
    always_on        = true
    ftps_state       = "Disabled"
  }

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  tags = {
    Environment = var.environment
    Role        = "AdminDashboard-Staging"
    CreatedBy   = "terraform"
  }
}

# ----------------------------------------------------------------------------
# 3. TensorFlow API Web App (Docker container from ACR)
# ----------------------------------------------------------------------------
resource "azurerm_linux_web_app" "tf_api" {
  name                = "${var.name_prefix}-${var.environment}-tfapiwebapp"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_app_service_plan.asp.id

  site_config {
    # Use Docker image from ACR
    minimum_tls_version  = "1.2"
    ftps_state           = "Disabled"
    always_on            = true
  }

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    # Do not run-from-package; image is pulled at runtime
    "WEBSITE_RUN_FROM_PACKAGE" = "0"
  }

  tags = {
    Environment = var.environment
    Role        = "TensorFlowAPI"
    CreatedBy   = "terraform"
  }
}
