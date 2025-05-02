# Create a Managed Identity
resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = lower("id-${var.project_name}-${var.environment}-${random_integer.random_suffix.result}")
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
    created-on  = timestamp()
  })

  #lifecycle {
  #  prevent_destroy = true
  #}
}

resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}