output "acr_id" {
  description = "Resource ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_login_server" {
  description = "Login server (e.g., <name>.azurecr.io) of the ACR"
  value       = azurerm_container_registry.acr.login_server
}
