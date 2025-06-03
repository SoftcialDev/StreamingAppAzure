
# ----------------------------------------------------------------------------
# 1. Storage Account for Azure Functions (used by app for runtime files)
# ----------------------------------------------------------------------------
resource "azurerm_storage_account" "func_sa" {
  name                     = "${var.name_prefix}${var.environment}funcsa"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.environment
    Role        = "FunctionAppStorage"
    CreatedBy   = "terraform"
  }
}

# ----------------------------------------------------------------------------
# 2. Consumption Plan for Azure Functions (Dynamic)
# ----------------------------------------------------------------------------
resource "azurerm_app_service_plan" "func_plan" {
  name                = "${var.name_prefix}-${var.environment}-funcplan"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

  tags = {
    Environment = var.environment
    Role        = "FunctionAppPlan"
    CreatedBy   = "terraform"
  }
}

# ----------------------------------------------------------------------------
# 3. Azure Function App (Node/TypeScript runtime)
# ----------------------------------------------------------------------------
resource "azurerm_function_app" "function_app" {
  name                       = "${var.name_prefix}-${var.environment}-functionapp"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.func_plan.id
  storage_account_name       = azurerm_storage_account.func_sa.name
  storage_account_access_key = azurerm_storage_account.func_sa.primary_access_key
  version                    = "~4"          # Azure Functions v4

  identity {
    type = "SystemAssigned"
  }

  site_config {
    # Runtime for Node.js (TypeScript compiled to JS)
    linux_fx_version = "NODE|20-lts"
  }

  app_settings = {
    # System-assigned managed identity endpoint
    "WEBSITE_RUN_FROM_PACKAGE"     = "1"
    "WEBSITE_NODE_DEFAULT_VERSION" = "20"
    # Connect string for Service Bus (populated at runtime using Managed Identity)
    "SERVICEBUS_NAMESPACE_ID"      = var.servicebus_namespace_id
    # Connect string for Cosmos DB (using Managed Identity)
    "COSMOSDB_ACCOUNT_ID"          = var.cosmosdb_account_id
    # Key Vault URI for retrieving secrets via Managed Identity
    "KEYVAULT_URI"                 = var.keyvault_uri
    # AzureWebJobsStorage is required; AzureRM will autofill from the storage account
  }

  tags = {
    Environment = var.environment
    Role        = "ServerlessAPI"
    CreatedBy   = "terraform"
  }
}

# ----------------------------------------------------------------------------
# 4. Grant RBAC roles to Function App’s Managed Identity
# ----------------------------------------------------------------------------

# 4.a. Service Bus Data Sender on the namespace
resource "azurerm_role_assignment" "servicebus_sender" {
  scope                = var.servicebus_namespace_id
  role_definition_name = "Azure Service Bus Data Sender"

  # INDEX [0] to access principal_id from identity list :contentReference[oaicite:3]{index=3}
  principal_id         = azurerm_function_app.function_app.identity[0].principal_id
}

# 4.b. Cosmos DB Built-in Data Contributor on the Cosmos account
resource "azurerm_role_assignment" "cosmos_data_contributor" {
  scope                = var.cosmosdb_account_id
  role_definition_name = "Cosmos DB Built-in Data Contributor"
  
  # INDEX [0] here as well :contentReference[oaicite:4]{index=4}
  principal_id         = azurerm_function_app.function_app.identity[0].principal_id
}

# 4.c. Key Vault Reader on the Key Vault
resource "azurerm_key_vault_access_policy" "func_kv_reader" {
  key_vault_id = var.keyvault_uri

  # INDEX [0] to grab tenant_id and principal_id :contentReference[oaicite:5]{index=5}
  tenant_id = azurerm_function_app.function_app.identity[0].tenant_id
  object_id = azurerm_function_app.function_app.identity[0].principal_id

  secret_permissions = [
    "Get",   # Must use Title-case :contentReference[oaicite:6]{index=6}
    "List"
  ]
}
