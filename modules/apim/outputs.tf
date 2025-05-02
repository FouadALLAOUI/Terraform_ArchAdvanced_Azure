output "apim_id" {
  description = "The ID of the API Management instance"
  value       = azurerm_api_management.apim.id
}

output "apim_name" {
  description = "The name of the API Management instance"
  value       = azurerm_api_management.apim.name
}

output "apim_gateway_url" {
  description = "The gateway URL of the API Management instance"
  value       = azurerm_api_management.apim.gateway_url
}

output "apim_identity" {
  description = "The identity details of the API Management instance"
  value       = azurerm_api_management.apim.identity
}

output "apis" {
  description = "Details of all deployed APIs"
  value = {
    for api_key, api in azurerm_api_management_api.apis : api_key => {
      id           = api.id
      name         = api.name
      display_name = api.display_name
      path         = api.path
      service_url  = api.service_url
      protocols    = api.protocols
    }
  }
}
