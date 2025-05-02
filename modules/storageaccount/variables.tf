variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "Environment (dev, staging, prod)"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created"
}

variable "account_tier" {
  type        = string
  description = "Storage Account Tier (Standard or Premium)"
  default     = "Standard"
}

variable "account_replication_type" {
  type        = string
  description = "Storage Account Replication Type (LRS, GRS, RAGRS, ZRS)"
  default     = "LRS"
}

variable "account_kind" {
  type        = string
  description = "Storage Account Kind (StorageV2, FileStorage, BlockBlobStorage)"
  default     = "StorageV2"
}

variable "allowed_ips" {
  type        = list(string)
  description = "List of allowed IP addresses"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to resources"
  default     = {}
} 
