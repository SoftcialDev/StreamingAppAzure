# main.tf (root module)
# ------------------------------------------------------------------------------
# This root module invokes all sub-modules (AAD, Service Bus, Cosmos DB, KeyVault, etc.).
# We no longer reference azurerm_key_vault.vault here; instead, we consume module.keyvault outputs.
# ------------------------------------------------------------------------------




###############################################################################
# 1. Azure AD: create CI/CD Service Principal                                 #
###############################################################################

# 1.a. Get current Terraform runner’s Object ID
data "azuread_client_config" "current" {}

# 1.b. Create an AAD Application for the pipeline
resource "azuread_application" "pipeline_app" {
  display_name = "${var.name_prefix}-Pipeline-SP-${var.environment}"
}

# 1.c. Create a Service Principal for that Application
resource "azuread_service_principal" "pipeline_sp" {
  # azuread_service_principal requires client_id = azuread_application.<name>.client_id 
  client_id = azuread_application.pipeline_app.client_id
}

# 1.d. Generate a strong random password for the SP
resource "random_password" "pipeline_sp_pwd" {
  length  = 24
  special = true
}

# Capture the SP’s object ID in a local variable so it is known at plan time
locals {
  pipeline_sp_id = azuread_service_principal.pipeline_sp.object_id
}

resource "azuread_service_principal_password" "pipeline_sp_secret" {
  service_principal_id = azuread_service_principal.pipeline_sp.id
  end_date             = timeadd(timestamp(), "240h")
}

# 1.e. Grant “Reader” on the Resource Group for the pipeline SP
resource "azurerm_role_assignment" "pipeline_reader" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.pipeline_sp.object_id
}


# ----------------------------------------------------------------------------
# 2. Create Resource Group
# ----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "EmployeeMonitoring"
    CreatedBy   = "terraform"
  }
}

###############################################################################
# 3. Module: Azure AD (App Registration, App Roles)                          #
###############################################################################
module "aad" {
  source       = "./modules/aad"
  name_prefix  = var.name_prefix
  environment  = var.environment
}

###############################################################################
# 4. Module: Service Bus (Namespace + Queue)                                  #
###############################################################################
module "servicebus" {
  source              = "./modules/servicebus"
  name_prefix         = var.name_prefix
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = var.servicebus_sku
}

# 4.a. Grant “Get/List” access policy on the Key Vault to the pipeline SP
resource "azurerm_key_vault_access_policy" "pipeline_sp_policy" {
  key_vault_id = module.keyvault.vault_id
  tenant_id    = data.azuread_client_config.current.tenant_id
  object_id    = local.pipeline_sp_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# 4.b. Assign built-in “Key Vault Secrets User” role at vault scope to the pipeline SP
resource "azurerm_role_assignment" "pipeline_kv_secrets" {
  scope                = module.keyvault.vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = local.pipeline_sp_id
}

###############################################################################
# 5. Module: Cosmos DB (Serverless, SQL API)                                  #
###############################################################################
module "cosmosdb" {
  source              = "./modules/cosmosdb"
  name_prefix         = var.name_prefix
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  consistency_level   = var.cosmos_consistency
}

###############################################################################
# 6. Module: Key Vault                                                       #
###############################################################################
module "keyvault" {
  source               = "./modules/keyvault"
  name_prefix          = var.name_prefix
  environment          = var.environment
  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  sku                  = var.keyvault_sku
  pipeline_sp_object_id = azuread_service_principal.pipeline_sp.id
}

###############################################################################
# 7. Module: Azure Container Registry (ACR)                                   #
###############################################################################
module "acr" {
  source               = "./modules/acr"
  name_prefix          = var.name_prefix
  environment          = var.environment
  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  sku                  = var.acr_sku

  akskubelet_identity_id = module.aks.kubelet_identity_id
}

###############################################################################
# 8. Module: AKS (LiveKit Infra)                                              #
###############################################################################
module "aks" {
  source               = "./modules/aks"
  name_prefix          = var.name_prefix
  environment          = var.environment
  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location

  acr_id               = module.acr.acr_id
  system_vm_size       = var.aks_system_vm_size
  system_node_count    = 1
  spot_vm_size         = var.aks_spot_vm_size
  aks_spot_max_count   = var.aks_spot_max_count
}

###############################################################################
# 9. Module: App Service (Admin Dashboard + TF API + Optional Slot)          #
###############################################################################
module "appservice" {
  source               = "./modules/appservice"
  name_prefix          = var.name_prefix
  environment          = var.environment
  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  enable_slot          = var.enable_slot
  tf_api_image         = var.tf_api_image
}

###############################################################################
# 10. Module: Azure Functions (Serverless API)                                #
###############################################################################
module "functions" {
  source                  = "./modules/functions"
  name_prefix             = var.name_prefix
  environment             = var.environment
  resource_group_name     = azurerm_resource_group.main.name
  location                = var.location
  servicebus_namespace_id = module.servicebus.namespace_id
  cosmosdb_account_id     = module.cosmosdb.cosmosdb_account_id
  # Use the vault URI exported by keyvault module 
  keyvault_id = module.keyvault.vault_id
  keyvault_uri            = module.keyvault.vault_uri
}

###############################################################################
# 11. Module: Storage (Installers + Recordings + Static Website)             #
###############################################################################
module "storage" {
  source                = "./modules/storage"
  name_prefix           = var.name_prefix
  environment           = var.environment
  resource_group_name   = azurerm_resource_group.main.name
  location              = var.location
  enable_static_website = var.enable_static_website
}
