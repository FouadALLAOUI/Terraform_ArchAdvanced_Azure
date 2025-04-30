# Create a random suffix
resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}

# Create a Cosmos DB NoSql
resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = "cosmosdb-training-${random_integer.random_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session" # Strong, BoundedStaleness, Session, ConsistentPrefix, Eventual
  }

  backup {
    type                = "Periodic"
    interval_in_minutes = 1440
    retention_in_hours  = 24
    storage_redundancy  = "Local"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = false
  }

  tags = {
    environment = "training"
    project     = "apim-integration"
    managed-by  = "terraform"
  }
}


# Create a Database in Cosmos DB NoSql
resource "azurerm_cosmosdb_sql_database" "cosmosdb" {
  name                = "test-database"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
}

# Create a Container in Cosmos DB NoSql
resource "azurerm_cosmosdb_sql_container" "cosmosdb" {
  name                = "test-container"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  database_name       = azurerm_cosmosdb_sql_database.cosmosdb.name
  partition_key_paths  = ["/id"]
  throughput          = 400
}