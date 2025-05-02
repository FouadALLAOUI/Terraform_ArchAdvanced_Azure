# Create a Resource Group
resource "azurerm_resource_group" "rg_dev" {
  name     = var.rg_name
  location = var.location

  tags = {
    environment = "training"
    project     = "apim-integration"
    managed-by  = "terraform"
  }
}

module "vm" {
  source = "./modules/vm"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
  subnet_id = module.network.subnet_id
  create_public_ip = true
  prefix = "cw-vm"
  environment = "dev"
  admin_username = "cwadmin"
  admin_password = "P@ssw0rd"
  tags = {
    environment = "dev"
  }
}

module "cosmosdb" {
  source            = "./modules/cosmosdb"
  rg_name           = azurerm_resource_group.resource_group.name
  location          = azurerm_resource_group.resource_group.location
  cosmosdb_name     = "cwcosmosdb"
  offer_type        = "Standard"
  kind              = "GlobalDocumentDB"
  consistency_level = "Session"
  databases = {
    "Dev-DB-Connected_Workers" = {
      name = "Dev-DB-Connected_Workers"
      containers = {
        "Dev-Container-Connected_Workers" = {
          name                = "Dev-Container-Connected_Workers"
          partition_key_paths = "/id"
          throughput          = 400
        }
      }
    }
  }
  additional_containers = {
    "Dev-DB-Connected_Workers" = {
      database_name       = "Dev-DB-Connected_Workers"
      name                = "Dev-Container-Connected_Workers"
      partition_key_paths = "/id"
      throughput          = 400
    }
  }
}

module "sqlserver" {
  source                        = "./modules/sqlserver"
  project_name                  = "cw-sqlsrvr"
  environment                   = "dev"
  resource_group_name           = azurerm_resource_group.resource_group.name
  location                      = azurerm_resource_group.resource_group.location
  administrator_login           = "sqladmin"
  administrator_login_password  = "P@ssw0rd"
  database_name                 = "Dev-DB-Connected_Workers"
  sku_name                      = "S0"
  storage_size_gb               = 10
  zone_redundant                = false
  backup_retention_days         = 7
  public_network_access_enabled = false
  allowed_ip_ranges             = ["10.0.0.0/8"]
  //allowed_subnet_ids = [azurerm_subnet.subnet.id]
  tags = {
    environment = "dev"
  }
}

module "acr" {
  source = "./modules/acr"
  rg_name = azurerm_resource_group.resource_group.name
  acr_name = "cwacr"
  location = azurerm_resource_group.resource_group.location
}

module "aks" {
  source = "./modules/aks"
  location = azurerm_resource_group.resource_group.location
  rg_name = azurerm_resource_group.resource_group.name
  cluster_name = "cw-aks"
  node_pool_name = "cwaksndpool"
  identity_type = "SystemAssigned"
  acr_id = module.acr.acr_id
  node_count = 2
  vm_size = "Standard_B2ms"
  acr_policy = "AcrPull"
  kubernetes_version = "1.30.0"
  enable_auto_scaling = false
  min_node_count = 1
  max_node_count = 3
  os_disk_size_gb = 30
  network_plugin = "azure"
  network_policy = "azure"
}

module "storageaccount" {
  source                   = "./modules/storageaccount"
  project_name             = "cw-accst"
  environment              = "dev"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  //allowed_ips = ["10.0.0.0/8"]
  tags = {
    environment = "dev"
  }
}

module "managedidentity" {
  source              = "./modules/managedidentity"
  project_name        = "Dev-RG-Connected_Workers"
  environment         = "dev"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  tags = {
    environment = "dev"
  }
}






/*
module "apim" {
  source          = "./modules/apim"
  rg_name         = azurerm_resource_group.resource_group.name
  location        = azurerm_resource_group.resource_group.location
  publisher_name  = "Connected Workers"
  publisher_email = "connectedworkers@connectedworkers.com"
  sku_name        = "Developer_1"
  api_name        = "cwapi"
  apim_name       = "devapimcw"
  tags = {
    Environment = "Development"
    Project     = "Connected Workers"
  }
  depends_on = [
    module.aks,
    module.cosmosdb,
    module.acr
  ]
}

/*
module "keyvault" {
  source = "./modules/keyvault"
  project_name = "cw-keyvault"
  environment = "dev"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location 
  sku_name = "standard"
  enabled_for_disk_encryption = true
  enabled_for_deployment = true
  enable_rbac_authorization = true
  tags = {
    environment = "dev"
  } 

  //depends_on = [
  //  module.storageaccount,
  //  module.servicebus,
  //  module.sqlserver,
  //  module.eventhub
  //]
}
*/