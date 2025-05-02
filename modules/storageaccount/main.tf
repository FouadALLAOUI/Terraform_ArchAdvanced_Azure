# Create a Storage Account
resource "azurerm_storage_account" "storageaccount" {
  name                     = lower("st${replace(var.project_name, "-", "")}${var.environment}${random_integer.random_suffix.result}")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind            = var.account_kind
  min_tls_version        = "TLS1_2"
  
  blob_properties {
    versioning_enabled       = true
    container_delete_retention_policy {
      days = 7
    }
  }

  //network_rules {
  //  default_action = "Deny"
  //  ip_rules       = var.allowed_ips
  //  bypass         = ["AzureServices"]
  //}

  tags = merge(var.tags, {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
  })
}

resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}


