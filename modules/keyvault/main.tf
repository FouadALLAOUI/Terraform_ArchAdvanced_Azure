# Create a Key Vault
resource "azurerm_key_vault" "keyvault" {
  name                         = lower("kv-${var.project_name}-${var.environment}-${random_integer.random_suffix.result}")
  location                     = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.sku_name
  enabled_for_disk_encryption = var.enabled_for_disk_encryption
  enabled_for_deployment      = var.enabled_for_deployment
  enable_rbac_authorization   = var.enable_rbac_authorization
  
  # Temporarily disable these features during initial creation
  purge_protection_enabled    = false  # Changed from true
  soft_delete_retention_days  = 7 # This is the default values

  # Simplified network ACLs for initial creation
  network_acls {
    bypass                     = "AzureServices"
    default_action            = "Allow"
    ip_rules                  = []
    virtual_network_subnet_ids = []
  }

  tags = merge(var.tags, {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
    created-on  = timestamp()
  })

  //lifecycle {
  //  prevent_destroy = true
  //}

  timeouts {
    create = "60m"  # Increased from 30m
    delete = "60m"  # Increased from 30m
    read   = "10m"  # Increased from 5m
    update = "60m"  # Increased from 30m
  }
}

# Add a delay after Key Vault creation
resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_key_vault.keyvault]
  create_duration = "30s"
}

resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}

data "azurerm_client_config" "current" {}


