output "identity_id" {
  description = "The ID of the User Assigned Identity"
  value       = azurerm_user_assigned_identity.managed_identity.id
}

output "principal_id" {
  description = "The Principal ID associated with this Managed Service Identity"
  value       = azurerm_user_assigned_identity.managed_identity.principal_id
}

output "client_id" {
  description = "The Client ID associated with this Managed Service Identity"
  value       = azurerm_user_assigned_identity.managed_identity.client_id
}

output "tenant_id" {
  description = "The Tenant ID associated with this Managed Service Identity"
  value       = azurerm_user_assigned_identity.managed_identity.tenant_id
} 