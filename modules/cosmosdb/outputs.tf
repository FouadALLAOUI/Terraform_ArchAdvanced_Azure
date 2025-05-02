output "cosmos_db_id" {
  description = "The ID of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.id
}

output "cosmos_db_endpoint" {
  description = "The endpoint of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmos_db_primary_key" {
  description = "The primary key of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

#output "cosmos_db_connection_strings" {
#  description = "The connection strings of the Cosmos DB account"
#  value       = azurerm_cosmosdb_account.main.connection_strings
#  sensitive   = true
#}

output "database_names" {
  description = "The names of the created databases"
  value       = { for k, v in azurerm_cosmosdb_sql_database.databases : k => v.name }
}

output "container_names" {
  description = "The names of the created containers"
  value       = { for k, v in azurerm_cosmosdb_sql_container.containers : k => v.name }
}
