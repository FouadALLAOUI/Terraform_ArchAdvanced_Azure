# Create a random suffix
resource "random_string" "azurerm_api_management_name" {
  length  = 13
  lower   = true
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