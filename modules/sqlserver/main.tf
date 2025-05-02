# Create an SQL Server
resource "azurerm_mssql_server" "sqlserver" {
  name                         = lower("sql-${var.project_name}-${var.environment}-${random_integer.random_suffix.result}")
  location                     = var.location
  resource_group_name          = var.resource_group_name
  version                      = "12.0"
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  minimum_tls_version          = "1.2"
  public_network_access_enabled = var.public_network_access_enabled

  # Only include Azure AD admin if username and object_id are provided
  dynamic "azuread_administrator" {
    for_each = var.azuread_admin_username != null && var.azuread_admin_object_id != null ? [1] : []
    content {
      login_username = var.azuread_admin_username
      object_id     = var.azuread_admin_object_id
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
    created-on  = timestamp()
  })
}

# Create a SQL Database
resource "azurerm_mssql_database" "sqldatabase" {
  name                = var.database_name
  server_id          = azurerm_mssql_server.sqlserver.id
  sku_name           = var.sku_name
  max_size_gb        = var.storage_size_gb
  zone_redundant     = var.zone_redundant

  short_term_retention_policy {
    retention_days = var.backup_retention_days
  }

  tags = merge(var.tags, {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
  })
}

/*
resource "azurerm_mssql_firewall_rule" "allowed_ips" {
  for_each         = { for idx, ip in var.allowed_ip_ranges : idx => ip }
  name             = "AllowIP-${each.key}"
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = cidrhost(each.value, 0)
  end_ip_address   = cidrhost(each.value, -1)
}

resource "azurerm_mssql_virtual_network_rule" "subnet_rules" {
  for_each  = toset(var.allowed_subnet_ids)
  name      = "subnet-rule-${each.key}"
  server_id = azurerm_mssql_server.sqlserver.id
  subnet_id = each.value
}
*/

resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}