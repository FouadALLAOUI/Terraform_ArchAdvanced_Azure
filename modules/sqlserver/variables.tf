variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "Environment (dev, staging, prod)"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "administrator_login" {
  type        = string
  description = "The administrator login name for the SQL server"
}

variable "administrator_login_password" {
  type        = string
  description = "The administrator login password"
  sensitive   = true
}

variable "database_name" {
  type        = string
  description = "Name of the SQL database"
}

variable "sku_name" {
  type        = string
  description = "The SKU name for the database (e.g., GP_Gen5_2, BC_Gen5_2)"
  default     = "GP_Gen5_2"
}

variable "storage_size_gb" {
  type        = number
  description = "The max size of the database in gigabytes"
  default     = 32
}

variable "zone_redundant" {
  type        = bool
  description = "Whether to enable zone redundancy"
  default     = false
}

variable "backup_retention_days" {
  type        = number
  description = "Backup retention days for the database"
  default     = 7
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled"
  default     = false
}

variable "allowed_ip_ranges" {
  type        = list(string)
  description = "List of IP ranges to allow through the firewall"
  default     = []
}

variable "allowed_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to allow through the firewall"
  default     = []
}

variable "azuread_admin_username" {
  type        = string
  description = "Azure AD administrator username"
  default     = null
}

variable "azuread_admin_object_id" {
  type        = string
  description = "Azure AD administrator object ID"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to resources"
  default     = {}
}
