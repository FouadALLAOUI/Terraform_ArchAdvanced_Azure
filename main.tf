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

module "cosmosdb" {
  source              = "./modules/cosmosdb"
  resource_group_name = azurerm_resource_group.rg_dev.name
  location            = azurerm_resource_group.rg_dev.location
  tags = {
    environment = "training"
    project     = "apim-integration"
    managed-by  = "terraform"
  }
}













