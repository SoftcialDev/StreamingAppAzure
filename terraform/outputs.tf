# outputs.tf (root module)
# ------------------------------------------------------------------------------
# Outputs to surface useful resource IDs and endpoints from sub-modules.
# ------------------------------------------------------------------------------

###########################################
# 1. Azure AD (AAD) Outputs
###########################################

output "aad_application_id" {
  description = "Application (client) ID of the AAD Unified App Registration."
  value       = module.aad.app_client_id
}

output "aad_service_principal_id" {
  description = "Object ID of the Service Principal tied to the Unified App Registration."
  value       = module.aad.service_principal_id
}

output "aad_admin_app_role_id" {
  description = "App Role ID for 'Admin' in the Unified App Registration."
  value       = module.aad.admin_role_id
}

output "aad_employee_app_role_id" {
  description = "App Role ID for 'Employee' in the Unified App Registration."
  value       = module.aad.employee_role_id
}

###########################################
# 2. Azure Container Registry (ACR)
###########################################

output "acr_id" {
  description = "Resource ID of the Azure Container Registry."
  value       = module.acr.acr_id
}

output "acr_login_server" {
  description = "Login server of the ACR (e.g., '<name>.azurecr.io')."
  value       = module.acr.acr_login_server
}

###########################################
# 3. Azure Kubernetes Service (AKS)
###########################################

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = module.aks.aks_cluster_name
}

output "aks_cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = module.aks.aks_cluster_resource_id
}

output "aks_kubelet_identity_id" {
  description = "Object ID of the AKS cluster’s kubelet identity."
  value       = module.aks.kubelet_identity_id
}

output "aks_kube_config_raw" {
  description = "Raw, base64-encoded kubeconfig for AKS (sensitive)."
  value       = module.aks.aks_kube_config_raw
  sensitive   = true
}

###########################################
# 4. App Service (Linux Web Apps)
###########################################

output "appservice_plan_id" {
  description = "Resource ID of the Linux App Service Plan."
  value       = module.appservice.asp_id
}

output "admin_webapp_name" {
  description = "Name of the Admin Dashboard Web App."
  value       = module.appservice.admin_webapp_name
}

output "admin_webapp_default_hostname" {
  description = "Default hostname (URL) of the Admin Dashboard Web App."
  value       = module.appservice.admin_webapp_default_hostname
}

output "tf_api_webapp_name" {
  description = "Name of the TensorFlow API Web App."
  value       = module.appservice.tf_api_webapp_name
}

output "tf_api_webapp_default_hostname" {
  description = "Default hostname (URL) of the TensorFlow API Web App."
  value       = module.appservice.tf_api_webapp_default_hostname
}

###########################################
# 5. Azure Cosmos DB
###########################################

output "cosmosdb_account_id" {
  description = "Resource ID of the Cosmos DB account."
  value       = module.cosmosdb.cosmosdb_account_id
}

output "cosmosdb_primary_key" {
  description = "Primary key for accessing the Cosmos DB account (sensitive)."
  value       = module.cosmosdb.primary_master_key
  sensitive   = true
}

output "cosmosdb_endpoint" {
  description = "Endpoint URI of the Cosmos DB account."
  value       = module.cosmosdb.cosmosdb_endpoint
}

output "cosmosdb_database_name" {
  description = "Name of the Cosmos DB SQL database for metadata."
  value       = module.cosmosdb.database_id
}

output "cosmosdb_container_name" {
  description = "Name of the Cosmos DB SQL container for metadata."
  value       = module.cosmosdb.container_id
}

###########################################
# 6. Azure Functions
###########################################

output "functions_storage_account_name" {
  description = "Name of the Storage Account used by the Function App."
  value       = module.functions.storage_account_name
}

output "functions_plan_id" {
  description = "Resource ID of the Function App Consumption Plan."
  value       = module.functions.function_plan_id
}

output "function_app_name" {
  description = "Name of the Azure Function App."
  value       = module.functions.function_app_name
}

output "function_app_hostname" {
  description = "Default hostname (URL) of the Azure Function App."
  value       = module.functions.function_app_default_hostname
}

output "function_app_principal_id" {
  description = "Managed Identity Principal ID of the Function App."
  value       = module.functions.function_app_principal_id
}

###########################################
# 7. Azure Key Vault
###########################################

# **Use module.keyvault.vault_id and module.keyvault.vault_uri**, 
# because the Key Vault resource has been moved into modules/keyvault. 

output "vault_id" {
  description = "Resource ID of the Key Vault (from keyvault module)."
  value       = module.keyvault.vault_id
}

output "keyvault_uri" {
  description = "URI of the Key Vault (e.g., 'https://<name>.vault.azure.net/') (from keyvault module)."
  value       = module.keyvault.vault_uri
}

###########################################
# 8. Azure Service Bus
###########################################

output "servicebus_namespace_id" {
  description = "Resource ID of the Service Bus Namespace."
  value       = module.servicebus.namespace_id
}

output "servicebus_employee_queue_id" {
  description = "Resource ID of the EmployeeCommandQueue (requires sessions)."
  value       = module.servicebus.queue_id
}

###########################################
# 9. Azure Storage
###########################################

output "storage_account_name" {
  description = "Name of the primary Storage Account."
  value       = module.storage.storage_account_name
}

output "installers_container_name" {
  description = "Name of the container holding Electron installers."
  value       = module.storage.installers_container_name
}

output "recordings_container_name" {
  description = "Name of the container used for recordings."
  value       = module.storage.recordings_container_name
}

output "installers_sas_token" {
  description = "Read/List SAS token for the installers container (sensitive)."
  value       = module.storage.installers_sas_token
  sensitive   = true
}

output "static_website_endpoint" {
  description = "Static Website endpoint URL (if enabled)."
  value       = module.storage.static_website_endpoint
}
