variable "rg_name" {
  description = "The name of the resource group"
  type        = string
  default     = "Terraform_ArchAdvanced"
}

variable "location" {
  description = "The Azure region to deploy the resources"
  type        = string
  default     = "West Europe"
}

variable "admin_username" {
  description = "The username for the admin user"
  type        = string
  default     = "cwadmin"
}

variable "admin_password" {
  description = "The password for the admin user"
  type        = string
  default     = "ConnectedW0rkers!2025"
  sensitive   = true
}

variable "tags" {
  description = "The tags to apply to the resources"
  type        = map(string)
  default     = {
    environment = "dev"
  }
}
