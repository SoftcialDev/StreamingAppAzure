# main.tf (modules/aad)
# ------------------------------------------------------------------------------
# This module registers an Azure AD application with two app roles ("Admin", "Employee"),
# then patches in a redirect URI for MSAL, and creates an AAD Service Principal.
# ------------------------------------------------------------------------------

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.48.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

provider "azuread" {
  # Inherit tenant from root module
}

data "azuread_client_config" "current" {}

# Generate UUIDs for the "user_impersonation" scope and for two App Roles
resource "random_uuid" "scope_id"      {}
resource "random_uuid" "admin_role_id" {}
resource "random_uuid" "emp_role_id"   {}

data "azuread_application" "existing" {
  object_id = azuread_application.main.object_id
}

# 1. Create the AAD Application ("UnifiedApp") with basic redirect URIs
resource "azuread_application" "main" {
  display_name = "${var.name_prefix}-UnifiedApp-${var.environment}"
  owners       = [data.azuread_client_config.current.object_id]

  web {
    redirect_uris = [
      "http://localhost:5173/",
      "https://admin.${var.name_prefix}.com/"
    ]
  }

  api {
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

  app_role {
    allowed_member_types = ["User"]
    description          = "Admins can access the Admin Dashboard."
    display_name         = "Admin"
    enabled              = true
    id                   = random_uuid.admin_role_id.result
    value                = "Admin"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Employees can run the Electron application."
    display_name         = "Employee"
    enabled              = true
    id                   = random_uuid.emp_role_id.result
    value                = "Employee"
  }
}

/*
# 2. Patch in the Electron/MSAL redirect URI (msal://<client_id>/auth)
resource "azuread_application_redirect_uris" "electron" {
  count          = var.create_redirect_uri ? 1 : 0
  application_id = azuread_application.main.id
  type           = "Web"

  redirect_uris = [
    "msal://${azuread_application.main.client_id}/auth"
  ]
}
*/
# 3. Create a Service Principal for the registered Azure AD Application
resource "azuread_service_principal" "main" {
  # Must reference client_id 
  client_id = azuread_application.main.client_id
}

# 4. Create two Azure AD Security Groups: "Admins" and "Employees"
resource "azuread_group" "admins" {
  display_name     = "${var.name_prefix}-Admins-${var.environment}"
  security_enabled = true
}

resource "azuread_group" "employees" {
  display_name     = "${var.name_prefix}-Employees-${var.environment}"
  security_enabled = true
}

# 5. Add the current user/SP to the "Admins" group
resource "azuread_group_member" "seed_admin_current" {
  # Use .object_id (a GUID), not .id (a full URI) 
  group_object_id  = azuread_group.admins.object_id
  member_object_id = data.azuread_client_config.current.object_id
}

# 6. Assign the "Admin" App Role to the Admins group
resource "azuread_app_role_assignment" "admins_role" {
  principal_object_id = azuread_group.admins.object_id
  app_role_id         = random_uuid.admin_role_id.result
  resource_object_id  = azuread_service_principal.main.object_id
}

# 7. Assign the "Employee" App Role to the Employees group
resource "azuread_app_role_assignment" "employees_role" {
  principal_object_id = azuread_group.employees.object_id
  app_role_id         = random_uuid.emp_role_id.result
  resource_object_id  = azuread_service_principal.main.object_id
}
