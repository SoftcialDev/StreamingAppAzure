# ----------------------------------------------------------------------------
# 1. Admin Dashboard Web App (Linux, Node 20 LTS, ZIP deploy)
# ----------------------------------------------------------------------------

resource "azurerm_linux_web_app" "admin" {
  name                = "${var.name_prefix}-${var.environment}-adminwebapp"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_app_service_plan.asp.id

  site_config {
    always_on             = true
    ftps_state            = "Disabled"
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
# 2. Optional staging slot for Admin Web App
# ----------------------------------------------------------------------------

resource "azurerm_app_service_slot" "admin_staging" {
  count               = var.enable_slot ? 1 : 0
  name                = "staging"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.asp.id
  app_service_name    = azurerm_linux_web_app.admin.name

  site_config {
    linux_fx_version      = "NODE|20-lts"
    # Removed minimum_tls_version as it is not valid for app service slot
    always_on             = true
    ftps_state            = "Disabled"
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
    linux_fx_version      = "DOCKER|${var.tf_api_image}"
    minimum_tls_version   = "1.2"
    ftps_state            = "Disabled"
    always_on             = true
  }

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "0"
  }

  tags = {
    Environment = var.environment
    Role        = "TensorFlowAPI"
    CreatedBy   = "terraform"
  }
}
