# File: terraform/providers.tf

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # Azure Resource Manager provider for ARM resources (AKS, App Service, Service Bus, etc.)
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }

    # Azure Active Directory provider v3 for App Registrations, Groups, App Roles
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0.0"
    }

    # Random provider to generate stable UUIDs
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }

  backend "azurerm" {
    # These resources must exist before running `terraform init`
    resource_group_name  = "RG-TerraformState"
    storage_account_name = "tfstatecollette123"
    container_name       = "terraform-state"
    key                  = "collettehealth-prod.tfstate"
  }
}

provider "azurerm" {
  features {}  # Required by azurerm >= v2
  # Optionally lock to a specific subscription and tenant:
  # subscription_id = var.subscription_id
  # tenant_id       = var.tenant_id
}

provider "azuread" {
  # By default, uses the same Azure CLI or Service Principal credentials as AzureRM.
  tenant_id = var.tenant_id
}

provider "random" {}
