output "asp_id" {
  description = "Resource ID of the App Service Plan"
  value       = azurerm_app_service_plan.asp.id
}

output "admin_webapp_name" {
  description = "Name of the Admin Dashboard Web App"
  value       = azurerm_linux_web_app.admin.name
}

output "admin_webapp_default_hostname" {
  description = "Default hostname (URL) of the Admin Dashboard Web App"
  value       = azurerm_linux_web_app.admin.default_hostname
}

output "admin_staging_slot_name" {
  description = "Name of the staging slot for the Admin Web App (if enabled)"
  value       = length(azurerm_app_service_slot.admin_staging) > 0 ? azurerm_app_service_slot.admin_staging[0].name : ""
}

output "tf_api_webapp_name" {
  description = "Name of the TensorFlow API Web App"
  value       = azurerm_linux_web_app.tf_api.name
}

output "tf_api_webapp_default_hostname" {
  description = "Default hostname (URL) of the TensorFlow API Web App"
  value       = azurerm_linux_web_app.tf_api.default_hostname
}
