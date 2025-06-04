# modules/keyvault/main.tf
# ------------------------------------------------------------------------------
# This module creates:
#   1. An Azure Key Vault (standard or premium)
#   2. An access policy granting the current Terraform user/SP full secret permissions
#
# The conditional logic for a pipeline SP is removed and moved into the root module.
# ------------------------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.48.0"
    }
  }
}

# Inherit providers (azurerm & azuread) from the root module

data "azuread_client_config" "current" {}

# 1. Create the Key Vault (standard or premium, minimal ACLs)
resource "azurerm_key_vault" "vault" {
  name                        = "${substr(var.name_prefix, 0, 12)}${substr(var.environment, 0, 1)}kv"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azuread_client_config.current.tenant_id
  sku_name                    = var.sku == "premium" ? "premium" : "standard"
  purge_protection_enabled    = false

  tags = {
    Environment = var.environment
    Role        = "KeyVault"
    CreatedBy   = "terraform"
  }
}

# 2. Grant the current Terraform user/SP full secret permissions:
#    (Get, List, Set, Delete)
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = data.azuread_client_config.current.tenant_id
  object_id    = data.azuread_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}
