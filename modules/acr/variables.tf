variable "location" {
  description = "Location for the Azure Container Registry"
  type        = string
  default     = "West Europe"
}

variable "rg_name" {
  description = "Name of the existing resource group for the Azure Container Registry"
  type        = string
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (only alphanumeric characters allowed)"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.acr_name))
    error_message = "ACR name can only contain alphanumeric characters."
  }
}

variable "sku" {
  description = "SKU of the Azure Container Registry (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"
}

variable "enable_admin" {
  description = "Enable admin user for the Azure Container Registry"
  type        = bool
  default     = false
}
