output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "back_subnet_id" {
  description = "The ID of the back subnet"
  value       = azurerm_subnet.back_subnet.id
}

output "front_subnet_id" {
  description = "The ID of the front subnet"
  value       = azurerm_subnet.front_subnet.id
}

output "data_subnet_id" {
  description = "The ID of the data subnet"
  value       = azurerm_subnet.data_subnet.id
}

# This is the subnet that should be used for VMs
output "subnet_id" {
  description = "The ID of the default subnet (back) for VMs"
  value       = azurerm_subnet.back_subnet.id
}
