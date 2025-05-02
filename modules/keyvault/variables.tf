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

variable "sku_name" {
  type        = string
  description = "The SKU name of the Key Vault (standard or premium)"
  default     = "standard"
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Enable Key Vault for disk encryption"
  default     = true
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Enable Key Vault for deployment"
  default     = true
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Enable RBAC authorization for Key Vault"
  default     = true
}

variable "network_acls" {
  type = object({
    bypass                    = string
    default_action           = string
    ip_rules                 = list(string)
    subnet_ids               = list(string)
  })
  description = "Network ACLs for the Key Vault"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to resources"
  default     = {}
} 