# File: terraform/environments/prod.tfvars

name_prefix             = "collettehealthprod"
location                = "eastus2"
environment             = "prod"
resource_group_name     = "collettehealthprod-rg"
subscription_id         = "af90c465-cc8e-46d8-a0eb-ee471b4313a3"
tenant_id               = "c6f9ef6d-6027-416d-91f9-72ea35c9dac5"
enable_slot             = true

servicebus_sku          = "Standard"
cosmos_consistency      = "Session"
acr_sku                 = "Premium"

aks_system_vm_size      = "Standard_B2s"
aks_spot_vm_size        = "Standard_D4as_v5"

tf_api_image            = "collettehealthprodacr.azurecr.io/tf-api:prod-latest"
livekit_image           = "collettehealthprodacr.azurecr.io/livekit:prod-latest"

keyvault_sku            = "premium"

initial_admin_principals = [
  "22222222-3333-4444-5555-666666666666",
  "77777777-8888-9999-0000-aaaaaaaaaaaa"
]

pipeline_sp_object_id    = "bbbbbbbb-cccc-dddd-eeee-ffffffffffff"
