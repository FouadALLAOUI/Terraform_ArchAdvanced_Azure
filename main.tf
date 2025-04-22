# Create a Resource Group
resource "azurerm_resource_group" "example" {
  name     = "Terraform_ArchAdvanced"
  location = "West Europe"
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-training"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-training"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP address
resource "azurerm_public_ip" "publicip" {
  name                = "publicip-training"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  domain_name_label   = "terraform-archadvanced"
}

# Create a network interface
resource "azurerm_network_interface" "nic" {
  name                = "nic-training"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  ip_configuration {
    name                          = "ipconfig-training"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}


/*
# Create a random suffix
resource "random_string" "azurerm_api_management_name" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

# Create an API Management
resource "azurerm_api_management" "apimtraining" {
  name                = "apimtraining-${random_integer.random_suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  publisher_name      = "My Company"
  publisher_email     = "company@terraform.io"

  sku_name = "Developer_1"
}
*/

# Create a random suffix
resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}

# Create a Cosmos DB NoSql
resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = "cosmosdb-training-${random_integer.random_suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover = false
  enable_free_tier          = true

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
    location          = azurerm_resource_group.example.location
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
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
}

# Create a Container in Cosmos DB NoSql
resource "azurerm_cosmosdb_sql_container" "cosmosdb" {
  name                = "test-container"
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  database_name       = azurerm_cosmosdb_sql_database.cosmosdb.name
  partition_key_path  = "/id"
}


# Create a Service Bus
resource "azurerm_servicebus_namespace" "servicebus" {
  name                = "servicebus-training-${random_integer.random_suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
  tags = {
    environment = "training"
    project     = "servicebus-integration"
    managed-by  = "terraform"
  }
}

# Create a Service Bus Topic
resource "azurerm_servicebus_topic" "servicebus" {
  name                = "topic-servicebus-training-${random_integer.random_suffix.result}"
  namespace_id        = azurerm_servicebus_namespace.servicebus.id
  enable_partitioning = true
}

# Create a Service Bus Subscription
resource "azurerm_servicebus_subscription" "servicebus" {
  name               = "subscription-servicebus-training-${random_integer.random_suffix.result}"
  topic_id           = azurerm_servicebus_topic.servicebus.id
  max_delivery_count = 10
}

# Create a Service Bus Queue
resource "azurerm_servicebus_queue" "servicebus" {
  name                = "queue-servicebus-training-${random_integer.random_suffix.result}"
  namespace_id        = azurerm_servicebus_namespace.servicebus.id
  enable_partitioning = true
}


# Create an SQL Server
resource "azurerm_mssql_server" "sqlserver" {
  name                         = "sqlserver-training-${random_integer.random_suffix.result}"
  location                     = azurerm_resource_group.example.location
  resource_group_name          = azurerm_resource_group.example.name
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd"
  //minimum_tls_version          = "1.2"
  //public_network_access_enabled = false
  tags = {
    environment = "training"
    project     = "sql-integration"
    managed-by  = "terraform"
  }
}

# Create a SQL Database
resource "azurerm_mssql_database" "sqldatabase" {
  name      = "sqldatabase-training-${random_integer.random_suffix.result}"
  server_id = azurerm_mssql_server.sqlserver.id
  tags = {
    environment = "training"
    project     = "sql-integration"
    managed-by  = "terraform"
  }
}


# Create a Managed Identity
resource "azurerm_user_assigned_identity" "managedidentity" {
  name                = "managedidentity-training-${random_integer.random_suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tags = {
    environment = "training"
    project     = "managedidentity-integration"
    managed-by  = "terraform"
  }
}

/*
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "example-aks1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}
*/





