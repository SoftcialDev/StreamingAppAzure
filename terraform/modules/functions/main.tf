# ----------------------------------------------------------------------------
# 1. Storage Account for Azure Functions (runtime files)
#
# Cost optimizations:
#  - Use Standard_LRS for the lowest‐cost redundancy (LRS).
#  - Shorten name to meet Azure’s 3–24 lowercase alphanumeric requirement.
# ----------------------------------------------------------------------------
resource "azurerm_storage_account" "func_sa" {
  name                     = "${substr(var.name_prefix, 0, 12)}${substr(var.environment, 0, 5)}fsa"
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
#
# Cost optimizations:
#  - “Y1” Dynamic plan automatically scales to zero when idle (no flat VM fee).
# ----------------------------------------------------------------------------
resource "azurerm_app_service_plan" "func_plan" {
  name                = "${var.name_prefix}-${var.environment}-funcpl"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"  # Billed per execution; scales to zero when idle.
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
#
# Cost optimizations:
#  - Runs on a consumption plan (“Y1”), so no baseline VM cost.
#  - Managed Identity for secure access to other resources.
# ----------------------------------------------------------------------------
resource "azurerm_function_app" "function_app" {
  name                       = "${var.name_prefix}-${var.environment}-functionapp"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.func_plan.id
  storage_account_name       = azurerm_storage_account.func_sa.name
  storage_account_access_key = azurerm_storage_account.func_sa.primary_access_key
  version                    = "~4"  # Azure Functions v4

  identity {
    type = "SystemAssigned"
  }

  site_config {
    
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"     = "1"
    "WEBSITE_NODE_DEFAULT_VERSION" = "20"
    "SERVICEBUS_NAMESPACE_ID"      = var.servicebus_namespace_id
    "COSMOSDB_ACCOUNT_ID"          = var.cosmosdb_account_id
    "KEYVAULT_URI"                 = var.keyvault_uri
    # Note: AzureWebJobsStorage will be auto‐populated by AzureRM if omitted.
  }

  tags = {
    Environment = var.environment
    Role        = "ServerlessAPI"
    CreatedBy   = "terraform"
  }
}

# ----------------------------------------------------------------------------
# 4. Grant RBAC roles to Function App’s Managed Identity
#    so it can communicate with Service Bus, Cosmos DB, and Key Vault.
# ----------------------------------------------------------------------------

# 4.a. Service Bus Data Sender
resource "azurerm_role_assignment" "servicebus_sender" {
  scope                = var.servicebus_namespace_id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = azurerm_function_app.function_app.identity[0].principal_id
}
/*
# 4.b. Cosmos DB Built‐in Data Contributor
resource "azurerm_role_assignment" "cosmos_data_contributor" {
  scope                = var.cosmosdb_account_id
  role_definition_name = "Cosmos DB Built-in Data Contributor"
  principal_id         = azurerm_function_app.function_app.identity[0].principal_id
}
*/
# 4.c. Key Vault Reader
resource "azurerm_key_vault_access_policy" "func_kv_reader" {

  key_vault_id = var.keyvault_id   

  tenant_id = azurerm_function_app.function_app.identity[0].tenant_id
  object_id = azurerm_function_app.function_app.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}
