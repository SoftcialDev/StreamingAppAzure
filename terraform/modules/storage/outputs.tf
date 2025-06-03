# File: modules/storage/outputs.tf

output "storage_account_name" {
  description = "Name of the primary Storage Account"
  value       = azurerm_storage_account.sa.name
}

output "installers_container_name" {
  description = "Name of the container for Electron installers"
  value       = azurerm_storage_container.installers.name
}

output "recordings_container_name" {
  description = "Name of the container for recordings"
  value       = azurerm_storage_container.recordings.name
}

output "installers_sas_token" {
  description = "SAS token granting read/list permissions on the installers container"
  value       = data.azurerm_storage_account_sas.installers_sas.sas
  sensitive   = true
}

output "static_website_endpoint" {
  description = "Primary static website URL (if enabled)"
  value = var.enable_static_website ? azurerm_storage_account.sa.primary_web_endpoint : ""
  depends_on  = [ azurerm_storage_account_static_website.static_site ]
}
