output "vm_id" {
  description = "The ID of the virtual machine"
  value       = module.vm.vm_id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = module.vm.vm_name
}

output "private_ip_address" {
  description = "The private IP address of the virtual machine"
  value       = module.vm.private_ip_address
}

output "public_ip_address" {
  description = "The public IP address of the virtual machine"
  value       = module.vm.public_ip_address
}






