# modules/keyvault/outputs.tf
# ------------------------------------------------------------------------------
# Outputs for downstream modules or automation pipelines.
# ------------------------------------------------------------------------------

output "vault_id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.vault.id
}

output "vault_uri" {
  description = "URI of the Key Vault (e.g., https://<name>.vault.azure.net/)."
  value       = azurerm_key_vault.vault.vault_uri
}


