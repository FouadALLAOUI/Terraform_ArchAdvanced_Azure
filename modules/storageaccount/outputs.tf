output "storage_account_id" {
  description = "The ID of the Storage Account"
  value       = azurerm_storage_account.storageaccount.id
}

output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = azurerm_storage_account.storageaccount.name
}

output "primary_access_key" {
  description = "The primary access key for the Storage Account"
  value       = azurerm_storage_account.storageaccount.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The primary connection string for the Storage Account"
  value       = azurerm_storage_account.storageaccount.primary_connection_string
  sensitive   = true
} 