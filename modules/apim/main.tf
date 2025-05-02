# Create API Management instance
resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = var.location
  resource_group_name = var.rg_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name           = var.sku_name

  identity {
    type = "SystemAssigned"
  }

  protocols {
    enable_http2 = true
  }

  security {
    enable_backend_ssl30  = false
    enable_backend_tls10  = false
    enable_backend_tls11  = false
    enable_frontend_ssl30 = false
    enable_frontend_tls10 = false
    enable_frontend_tls11 = false
  }

  tags = var.tags
}

# Create APIs within APIM
resource "azurerm_api_management_api" "apis" {
  for_each            = var.apis
  name                = each.value.name
  resource_group_name = var.rg_name
  api_management_name = azurerm_api_management.apim.name
  revision            = each.value.revision
  display_name        = each.value.display_name
  path                = each.value.path
  protocols           = each.value.protocols
  service_url         = each.value.service_url
  
  import {
    content_format = each.value.content_format
    content_value  = each.value.content_value
  }
}

# Add API policy if specified
resource "azurerm_api_management_api_policy" "api_policies" {
  for_each            = var.api_policies
  api_name            = each.value.api_name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.rg_name
  xml_content        = each.value.xml_content
}