output "acr_id" {
  description = "The ID of the Azure Container Registry."
  value       = azurerm_container_registry.acr.id
  
}
output "login_server" {
  description = "URL that can be used to log into the Container Registry."
  value       = azurerm_container_registry.acr.login_server
}

output "fqdn" {
  description = "Azure Container Registry FQDN."
  value       = azurerm_container_registry.acr.login_server
}

output "admin_username" {
  description = "Username associated with the Container Registry admin account - if the admin account is enabled."
  value       = azurerm_container_registry.acr.admin_username
}

output "admin_password" {
  description = "Password associated with the Container Registry admin account - if the admin account is enabled."
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}
