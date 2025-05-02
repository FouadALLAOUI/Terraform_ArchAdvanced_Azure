variable "location" {
  description = "Location for the API Management instance"
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group for API Management"
  type        = string
}

variable "apim_name" {
  description = "The name of the API Management instance. Must be alphanumeric and between 1-50 characters"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,50}$", var.apim_name))
    error_message = "APIM name must be between 1-50 characters and can only contain alphanumeric characters and dashes"
  }
}

variable "publisher_name" {
  description = "The name of the publisher for the API Management instance"
  type        = string
}

variable "publisher_email" {
  description = "The email of the publisher for the API Management instance"
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the API Management instance"
  type        = string
  default     = "Developer_1"
  validation {
    condition     = contains(["Developer_1", "Basic_1", "Standard_1", "Premium_1"], var.sku_name)
    error_message = "SKU name must be one of: Developer_1, Basic_1, Standard_1, Premium_1"
  }
}

variable "api_name" {
  description = "The name of the API."
  type        = string
}

variable "apis" {
  description = "A map of API configurations for API Management"
  type = map(object({
    name           = string
    revision       = string
    display_name   = string
    path           = string
    protocols      = list(string)
    service_url    = string
    content_format = string
    content_value  = string
  }))
  default = {}
}

variable "api_policies" {
  description = "A map of API policies to apply"
  type = map(object({
    api_name     = string
    xml_content = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}