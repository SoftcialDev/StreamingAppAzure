# ----------------------------------------------------------------------------
# 1. Create the Key Vault instance (soft-delete enabled, purge protection optional)
# ----------------------------------------------------------------------------
resource "azurerm_key_vault" "vault" {
  name                        = "${var.name_prefix}-${var.environment}-kv"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.sku == "premium" ? "premium" : "standard"
  # soft_delete_enabled is enabled by default and cannot be disabled
  purge_protection_enabled    = false         # Consider enabling in stricter environments

  # Allow trusted Microsoft services (e.g., Functions) to bypass network restrictions
  # network_acls { ... } can be configured if you need VNet restrictions

  tags = {
    Environment = var.environment
    Role        = "KeyVault"
    CreatedBy   = "terraform"
  }
}

# ----------------------------------------------------------------------------
# 2. Grant secret permissions to initial principals (users/service principals)
# ----------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "initial_admins" {
  for_each = toset(var.initial_principals)

  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}


# ----------------------------------------------------------------------------
# 3. Grant secret permissions to pipeline service principal (if specified)
# ----------------------------------------------------------------------------

resource "azurerm_key_vault_access_policy" "pipeline_sp" {
  count        = var.pipeline_sp_object_id != "" ? 1 : 0
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.pipeline_sp_object_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# ----------------------------------------------------------------------------
# Data source to retrieve current tenant ID for access policies
# ----------------------------------------------------------------------------
data "azurerm_client_config" "current" {}
