# outputs.tf (modules/aad)
# ------------------------------------------------------------------------------
# Expose the AAD App Registration and related IDs to the root module.
# ------------------------------------------------------------------------------

output "app_object_id" {
  description = "Object ID of the Unified App Registration."
  value       = azuread_application.main.object_id
}

output "app_client_id" {
  description = "App ID (Client ID) of the Unified App Registration."
  value       = azuread_application.main.client_id
}

output "service_principal_id" {
  description = "Object ID of the Service Principal for the App Registration."
  value       = azuread_service_principal.main.object_id
}

output "admin_role_id" {
  description = "GUID of the 'Admin' App Role."
  value       = random_uuid.admin_role_id.result
}

output "employee_role_id" {
  description = "GUID of the 'Employee' App Role."
  value       = random_uuid.emp_role_id.result
}
