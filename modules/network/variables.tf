variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "main-vnet"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "back_subnet_prefix" {
  description = "Address prefix for the back subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "front_subnet_prefix" {
  description = "Address prefix for the front subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "data_subnet_prefix" {
  description = "Address prefix for the data subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
