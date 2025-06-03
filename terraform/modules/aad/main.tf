############################################
# 1. Generate stable UUIDs for app roles  #
#    and for the OAuth2 permission scope  #
############################################
resource "random_uuid" "scope_id"      {}
resource "random_uuid" "admin_role_id" {}
resource "random_uuid" "emp_role_id"   {}

############################################
# 2. Create the Azure AD Application       #
############################################
resource "azuread_application" "main" {
  display_name = "${var.name_prefix}-UnifiedApp-${var.environment}"
  owners       = var.initial_admins

  web {
    # Allowed redirect URIs: React (dev+prod) and Electron
    redirect_uris = [
      "http://localhost:5173",
      "https://admin.${var.name_prefix}.com",
      "msal://${azuread_application.main.client_id}/auth"
    ]
  }

  api {
    # Issue version 2 tokens with scopes
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Allow this app to act on behalf of the signed-in user."
      admin_consent_display_name = "Access API as signed-in user"
      enabled                    = true
      id                         = random_uuid.scope_id.result
      type                       = "User"
      user_consent_description   = "Allow the app to call the API on your behalf."
      user_consent_display_name  = "Call API as you"
      value                      = "user_impersonation"
    }
  }

  # Define App Role: Admin
  app_role {
    allowed_member_types = ["User"]
    description          = "Admins can access the Admin Dashboard."
    display_name         = "Admin"
    enabled              = true
    id                   = random_uuid.admin_role_id.result
    value                = "Admin"
  }

  # Define App Role: Employee
  app_role {
    allowed_member_types = ["User"]
    description          = "Employees can run the Electron application."
    display_name         = "Employee"
    enabled              = true
    id                   = random_uuid.emp_role_id.result
    value                = "Employee"
  }
}

##################################################
# 3. Create a Service Principal for this App     #
##################################################
resource "azuread_service_principal" "main" {
  client_id = azuread_application.main.client_id
}

############################################
# 4. Create two Azure AD security groups  #
############################################
resource "azuread_group" "admins" {
  display_name     = "${var.name_prefix}-Admins-${var.environment}"
  security_enabled = true
}

resource "azuread_group" "employees" {
  display_name     = "${var.name_prefix}-Employees-${var.environment}"
  security_enabled = true
}

############################################
# 5. Add initial admins to the Admins group#
############################################
resource "azuread_group_member" "seed_admins" {
  for_each          = toset(var.initial_admins)
  group_object_id   = azuread_group.admins.id
  member_object_id  = each.value
}

####################################################
# 6. Assign App Role 'Admin' to Admins group       #
####################################################
resource "azuread_app_role_assignment" "admins_role" {
  principal_object_id           = azuread_group.admins.id
  app_role_id                   = random_uuid.admin_role_id.result
  resource_object_id = azuread_service_principal.main.id
}

####################################################
# 7. Assign App Role 'Employee' to Employees group #
####################################################
resource "azuread_app_role_assignment" "employees_role" {
  principal_object_id           = azuread_group.employees.id
  app_role_id                   = random_uuid.emp_role_id.result
  resource_object_id = azuread_service_principal.main.id
}
