variable "prefix" {
  type        = string
  description = "Prefix to be used in the name of resources"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, test, prod)"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet where NIC will be created"
}

variable "create_public_ip" {
  type        = bool
  description = "Whether to create a public IP for the VM"
  default     = true
}

variable "vm_size" {
  type        = string
  description = "Size of the VM"
  default     = "Standard_B1s"
}

variable "os_disk_name" {
  type        = string
  description = "Name of the OS disk"
  default     = ""
}

variable "os_disk_caching" {
  type        = string
  description = "Caching option for the OS disk"
  default     = "ReadWrite"
}

variable "os_disk_create_option" {
  type        = string
  description = "Create option for the OS disk"
  default     = "FromImage"
}

variable "os_disk_managed_disk_type" {
  type        = string
  description = "Type of managed disk for the OS disk"
  default     = "Standard_LRS"
}

variable "ubuntu_sku" {
  type        = string
  description = "SKU of Ubuntu server image"
  default     = "18.04-LTS"
}

variable "admin_username" {
  type        = string
  description = "Username for the VM admin"
  default     = "azureuser"
}

variable "admin_password" {
  type        = string
  description = "Password for the VM admin (must be at least 12 characters with lowercase, uppercase, number and special character)"
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
