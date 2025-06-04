output "storage_account_name" {
  description = "Name of the storage account used by the Function App"
  value       = azurerm_storage_account.func_sa.name
}

output "function_plan_id" {
  description = "Resource ID of the Function Consumption Plan"
  value       = azurerm_app_service_plan.func_plan.id
}

output "function_app_name" {
  description = "Name of the Azure Function App"
  value       = azurerm_function_app.function_app.name
}

output "function_app_default_hostname" {
  description = "Default hostname (URL) of the Function App"
  value       = azurerm_function_app.function_app.default_hostname
}

output "function_app_principal_id" {
  description = "Principal ID of the Function App’s managed identity"
  value       = azurerm_function_app.function_app.identity[0].principal_id
}


