# File: terraform/main.tf

# ----------------------------------------------------------------------------
# 1. Create the Resource Group
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

# ----------------------------------------------------------------------------
# 2. Module: Azure AD (App Registration, Groups, App Roles)
# ----------------------------------------------------------------------------
module "aad" {
  source              = "./modules/aad"
  name_prefix         = var.name_prefix
  environment         = var.environment
  initial_admins      = var.initial_admin_principals
  tenant_id           = var.tenant_id
}

# ----------------------------------------------------------------------------
# 3. Module: Service Bus (Namespace + Queue)
# ----------------------------------------------------------------------------
module "servicebus" {
  source              = "./modules/servicebus"
  name_prefix         = var.name_prefix
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = var.servicebus_sku
}

# ----------------------------------------------------------------------------
# 4. Module: Cosmos DB (Serverless, SQL API)
# ----------------------------------------------------------------------------
module "cosmosdb" {
  source              = "./modules/cosmosdb"
  name_prefix         = var.name_prefix
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  consistency_level   = var.cosmos_consistency
}

# ----------------------------------------------------------------------------
# 5. Module: Key Vault 
# ----------------------------------------------------------------------------
module "keyvault" {
  source                = "./modules/keyvault"
  name_prefix           = var.name_prefix
  environment           = var.environment              
  resource_group_name   = azurerm_resource_group.main.name
  location              = var.location
  sku                   = var.keyvault_sku
  initial_principals    = var.initial_admin_principals
  pipeline_sp_object_id = var.pipeline_sp_object_id
}

# ----------------------------------------------------------------------------
# 6. Module: Azure Container Registry (Premium, no admin user)
# ----------------------------------------------------------------------------
module "acr" {
  source               = "./modules/acr"
  name_prefix          = var.name_prefix
  environment          = var.environment
  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  sku                  = var.acr_sku

  # Grant AKS cluster pull permissions (kubelet identity)
  akskubelet_identity_id = module.aks.kubelet_identity_id
}

# ----------------------------------------------------------------------------
# 7. Module: AKS (LiveKit Infra)
# ----------------------------------------------------------------------------
module "aks" {
  source               = "./modules/aks"
  name_prefix          = var.name_prefix
  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  acr_id               = module.acr.acr_id
}

# ----------------------------------------------------------------------------
# 8. Module: App Service (Admin Dashboard + TF API + Optional Slot)
# ----------------------------------------------------------------------------
module "appservice" {
  source               = "./modules/appservice"
  name_prefix          = var.name_prefix
  environment          = var.environment
  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  enable_slot          = var.enable_slot
  tf_api_image         = var.tf_api_image
}

# ----------------------------------------------------------------------------
# 9. Module: Azure Functions (Serverless API)
# ----------------------------------------------------------------------------
module "functions" {
  source                    = "./modules/functions"
  name_prefix               = var.name_prefix
  environment               = var.environment
  resource_group_name       = azurerm_resource_group.main.name
  location                  = var.location
  servicebus_namespace_id   = module.servicebus.namespace_id
  cosmosdb_account_id       = module.cosmosdb.cosmosdb_account_id
  keyvault_uri              = module.keyvault.vault_uri
}

# ----------------------------------------------------------------------------
# 10. Module: Storage (Installers + Recordings + Static Website)
# ----------------------------------------------------------------------------
module "storage" {
  source                = "./modules/storage"
  name_prefix           = var.name_prefix
  environment           = var.environment
  resource_group_name   = azurerm_resource_group.main.name
  location              = var.location
  enable_static_website = true
}
