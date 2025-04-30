variable "location" {
  description = "The Azure location where the Cosmos DB account will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the Cosmos DB account will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the Cosmos DB account."
  type        = map(string)
  default     = {}
}











