output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.keyvault.id
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.keyvault.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.keyvault.vault_uri
}

/*
output "key_vault_identity" {
  description = "The identity of the Key Vault"
  value       = azurerm_key_vault.keyvault.identity
} 
*/