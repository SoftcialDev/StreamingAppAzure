# ----------------------------------------------------------------------------
# 1. Create Cosmos DB Account in Serverless mode (SQL API)
# ----------------------------------------------------------------------------
resource "azurerm_cosmosdb_account" "cosmos" {
  name                = "${var.name_prefix}-${var.environment}-cosmos"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  # Serverless capacity mode
  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = var.consistency_level
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  tags = {
    Environment = var.environment
    CreatedBy   = "terraform"
    Project     = "EmployeeMonitoring"
  }
}

# ----------------------------------------------------------------------------
# 2. Create a SQL Database for Recording Metadata
# ----------------------------------------------------------------------------
resource "azurerm_cosmosdb_sql_database" "metadata_db" {
  name                = "RecordingMetadataDB"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos.name

  throughput = 400
}

# ----------------------------------------------------------------------------
# 3. Create a SQL Container for Recording Metadata
# ----------------------------------------------------------------------------
resource "azurerm_cosmosdb_sql_container" "metadata_container" {
  name                = "Recordings"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.metadata_db.name

  partition_key_paths = ["/user"]
  throughput         = 400

  indexing_policy {
    indexing_mode = "consistent"
  }

  unique_key {
    paths = ["/user", "/startTimestamp"]
  }
}
