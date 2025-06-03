output "resource_group_name" {
  description = "Name of the Resource Group"
  value       = azurerm_resource_group.main.name
}

output "aad_app_client_id" {
  description = "Client ID of the unified Azure AD App Registration"
  value       = module.aad.app_client_id
}

output "service_principal_id" {
  description = "Object ID of the Service Principal for the App Registration"
  value       = module.aad.service_principal_id
}

output "admins_group_id" {
  description = "Object ID of the 'Admins' Azure AD group"
  value       = module.aad.group_admins_id
}

output "employees_group_id" {
  description = "Object ID of the 'Employees' Azure AD group"
  value       = module.aad.group_employees_id
}

output "servicebus_namespace_id" {
  description = "Resource ID of the Service Bus Namespace"
  value       = module.servicebus.namespace_id
}

output "cosmosdb_endpoint" {
  description = "Primary endpoint URI for Cosmos DB account"
  value       = module.cosmosdb.cosmosdb_endpoint
}

output "keyvault_uri" {
  description = "URI of the Key Vault instance"
  value       = module.keyvault.vault_uri
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster hosting LiveKit"
  value       = module.aks.aks_name
}



output "function_app_name" {
  description = "Name of the Azure Function App"
  value       = module.functions.function_app_name
}

