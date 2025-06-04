# ----------------------------------------------------------------------------
# 1. Create a Serverless Cosmos DB Account (SQL API)
#
# Cost optimizations:
#  - "EnableServerless" ensures you pay per operation rather than fixed throughput.
#  - We only define a single geo_location (no multi-region) to avoid extra charges.
# ----------------------------------------------------------------------------
resource "azurerm_cosmosdb_account" "cosmos" {
  name                = "${var.name_prefix}-${var.environment}-cosmos"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  # Enable serverless mode
  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = var.consistency_level
  }

  # Single-region, no geo-replication
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
# 2. Create a SQL Database (no throughput block => serverless auto-scaling)
# ----------------------------------------------------------------------------
resource "azurerm_cosmosdb_sql_database" "metadata_db" {
  name                = "RecordingMetadataDB"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
}

# ----------------------------------------------------------------------------
# 3. Create a SQL Container (no manual throughput => serverless auto-scale)
# ----------------------------------------------------------------------------
resource "azurerm_cosmosdb_sql_container" "metadata_container" {
  name                = "Recordings"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.metadata_db.name

  partition_key_paths = ["/user"]

  indexing_policy {
    indexing_mode = "consistent"
  }

  unique_key {
    paths = ["/user", "/startTimestamp"]
  }
}
