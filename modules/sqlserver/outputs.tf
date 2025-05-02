output "server_id" {
  description = "The ID of the SQL Server"
  value       = azurerm_mssql_server.sqlserver.id
}

output "server_name" {
  description = "The name of the SQL Server"
  value       = azurerm_mssql_server.sqlserver.name
}

output "server_fqdn" {
  description = "The fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.sqlserver.fully_qualified_domain_name
}

output "database_id" {
  description = "The ID of the SQL Database"
  value       = azurerm_mssql_database.sqldatabase.id
}

output "database_name" {
  description = "The name of the SQL Database"
  value       = azurerm_mssql_database.sqldatabase.name
}

output "connection_string" {
  description = "Connection string for the Azure SQL Database"
  value       = "Server=tcp:${azurerm_mssql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sqldatabase.name};Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;"
  sensitive   = true
}

output "server_identity" {
  description = "The identity of the SQL Server"
  value       = azurerm_mssql_server.sqlserver.identity
} 