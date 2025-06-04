# ------------------------------------------------------------------
# 1. Global / Common settings
# ------------------------------------------------------------------

name_prefix             = "collettehealthprod"           # Lowercase prefix for naming all resources
location                = "eastus2"                       # Azure region
environment             = "prod"                          # Deployment environment tag
resource_group_name     = "collettehealthprod-rg"         # Name of existing Resource Group
subscription_id         = "af90c465-cc8e-46d8-a0eb-ee471b4313a3"
tenant_id               = "a080ad22-43aa-4696-b40b-9b68b702c9f3"

# ------------------------------------------------------------------
# 2. App Service (no staging slot = cheaper)
# ------------------------------------------------------------------

enable_slot             = false                           # “true” only if you want a staging slot
tf_api_image            = "collettehealthprodacr.azurecr.io/tf-api:prod-latest"
livekit_image           = "collettehealthprodacr.azurecr.io/livekit:prod-latest"

# ------------------------------------------------------------------
# 3. Service Bus (Basic = cheapest)
# ------------------------------------------------------------------

servicebus_sku          = "Standard"                         # “Basic” is lowest-cost tier

# ------------------------------------------------------------------
# 4. Cosmos DB (Serverless, Session consistency)
# ------------------------------------------------------------------

cosmos_consistency      = "Session"                       # “Session” consistency

# ------------------------------------------------------------------
# 5. Azure Container Registry (Basic = cheapest)
# ------------------------------------------------------------------

acr_sku                 = "Basic"

# ------------------------------------------------------------------
# 6. AKS (Single B2s node pool, no spot pool by default)
# ------------------------------------------------------------------

aks_system_vm_size      = "Standard_B2s"
aks_spot_vm_size        = "Standard_D4as_v5"
aks_spot_max_count      = 1                               # set >0 to enable spot nodes

# ------------------------------------------------------------------
# 7. Key Vault (Standard = cheapest)
# ------------------------------------------------------------------

keyvault_sku            = "Standard"

# ------------------------------------------------------------------
# 8. CI/CD pipeline Service Principal
#     (Terraform will create it automatically; leave blank here)
# ------------------------------------------------------------------

pipeline_sp_object_id   = ""                               # Terraform’s main.tf creates this SP

# ------------------------------------------------------------------
# 9. Storage (enable static website if needed)
# ------------------------------------------------------------------

enable_static_website   = false

enable_kv_access_for_pipeline = true


create_redirect_uri    = true
create_role_assignment = true