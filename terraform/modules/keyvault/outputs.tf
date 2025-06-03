output "vault_uri" {
  description = "URI of the Key Vault instance (https://<name>.vault.azure.net/)"
  value       = azurerm_key_vault.vault.vault_uri
}

output "keyvault_id" {
  description = "Resource ID of the Key Vault"
  value       = azurerm_key_vault.vault.id
}
