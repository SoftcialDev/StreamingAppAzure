output "cosmosdb_account_id" {
  description = "Resource ID of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos.id
}

output "primary_master_key" {
  description = "Primary master key for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos.primary_key
  sensitive   = true
}

output "cosmosdb_endpoint" {
  description = "Primary endpoint URI for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos.endpoint
}

output "database_id" {
  description = "Name of the SQL database for metadata"
  value       = azurerm_cosmosdb_sql_database.metadata_db.name
}

output "container_id" {
  description = "Name of the SQL container for metadata"
  value       = azurerm_cosmosdb_sql_container.metadata_container.name
}
