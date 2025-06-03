output "app_client_id" {
  description = "Client ID of the unified Azure AD Application"
  value       = azuread_application.main.client_id
}

output "service_principal_id" {
  description = "Object ID of the Service Principal for the App Registration"
  value       = azuread_service_principal.main.id
}

output "scope_user_impersonation_id" {
  description = "GUID of the 'user_impersonation' OAuth2 permission scope"
  value       = random_uuid.scope_id.result
}

output "admin_role_id" {
  description = "GUID of the 'Admin' App Role"
  value       = random_uuid.admin_role_id.result
}

output "employee_role_id" {
  description = "GUID of the 'Employee' App Role"
  value       = random_uuid.emp_role_id.result
}

output "group_admins_id" {
  description = "Object ID of the Admins security group"
  value       = azuread_group.admins.id
}

output "group_employees_id" {
  description = "Object ID of the Employees security group"
  value       = azuread_group.employees.id
}
