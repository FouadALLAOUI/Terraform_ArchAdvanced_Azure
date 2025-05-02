output "vm_id" {
  description = "ID of the created virtual machine"
  value       = azurerm_virtual_machine.vm.id
}

output "vm_name" {
  description = "Name of the created virtual machine"
  value       = azurerm_virtual_machine.vm.name
}

output "private_ip_address" {
  description = "Private IP address of the virtual machine"
  value       = azurerm_network_interface.nic.private_ip_address
}

output "public_ip_address" {
  description = "Public IP address of the virtual machine (if created)"
  value       = var.create_public_ip ? azurerm_public_ip.pip[0].ip_address : null
}

output "network_interface_id" {
  description = "ID of the network interface created for the virtual machine"
  value       = azurerm_network_interface.nic.id
}

output "network_interface_name" {
  description = "Name of the network interface created for the virtual machine"
  value       = azurerm_network_interface.nic.name
}

output "os_disk_id" {
  description = "ID of the OS disk created for the virtual machine"
  value       = azurerm_virtual_machine.vm.storage_os_disk[0].managed_disk_id
}

output "os_disk_name" {
  description = "Name of the OS disk created for the virtual machine"
  value       = azurerm_virtual_machine.vm.storage_os_disk[0].name
}
