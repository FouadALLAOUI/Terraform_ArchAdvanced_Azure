variable "location" {
  description = "The location where the Cosmos DB account will be deployed"
  type        = string
}

variable "rg_name" {
  description = "The name of the existing resource group"
  type        = string
}

variable "cosmosdb_name" {
  description = "The name of the Cosmos DB account"
  type        = string
}

variable "offer_type" {
  description = "The offer type for the Cosmos DB account"
  type        = string
  default     = "Standard"
}

variable "kind" {
  description = "The kind of Cosmos DB to create"
  type        = string
  default     = "GlobalDocumentDB"
}

variable "consistency_level" {
  description = "The consistency level of the Cosmos DB account"
  type        = string
  default     = "Session"
}

variable "databases" {
  description = "Map of databases with their containers"
  type = map(object({
    name = string
    containers = map(object({
      name               = string
      partition_key_paths = string
      throughput        = number
    }))
  }))
  default = {}
}

# New variable for additional containers
variable "additional_containers" {
  description = "Additional containers to be created in existing databases"
  type = map(object({
    database_name       = string
    name               = string
    partition_key_paths = string
    throughput        = number
  }))
  default = {}
}
