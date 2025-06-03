
# ----------------------------------------------------------------------------
# 1. Create Storage Account (StorageV2, HTTPS only)
# ----------------------------------------------------------------------------
resource "azurerm_storage_account" "sa" {
  name                     = "${var.name_prefix}${var.environment}storage"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = {
    Environment = var.environment
    Role        = "PrimaryStorage"
    CreatedBy   = "terraform"
  }
}

# ----------------------------------------------------------------------------
# 2. (Optional) Enable Static Website Hosting
# ----------------------------------------------------------------------------
resource "azurerm_storage_account_static_website" "static_site" {
  count              = var.enable_static_website ? 1 : 0
  storage_account_id = azurerm_storage_account.sa.id
  index_document     = "index.html"
  error_404_document = "404.html"
}

# ----------------------------------------------------------------------------
# 3. Create Container for Electron installers (private)
# ----------------------------------------------------------------------------
resource "azurerm_storage_container" "installers" {
  name                  = "installers"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

# ----------------------------------------------------------------------------
# 4. Create Container for Recordings (private)
# ----------------------------------------------------------------------------
resource "azurerm_storage_container" "recordings" {
  name                  = "recordings"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

# ----------------------------------------------------------------------------
# 5. Generate a short-lived SAS token for the installers container
# ----------------------------------------------------------------------------
data "azurerm_storage_account_sas" "installers_sas" {
  connection_string       = azurerm_storage_account.sa.primary_connection_string
  https_only              = true
  start                   = timestamp()
  expiry                  = timeadd(timestamp(), "240h")   # 10 days

  permissions {
    read    = true
    list    = true
    write   = false
    delete  = false
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    file  = false
    queue = false
    table = false
  }
}

