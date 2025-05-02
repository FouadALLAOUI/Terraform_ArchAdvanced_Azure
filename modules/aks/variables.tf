variable "location" {
  description = "Location for the AKS cluster"
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group for the AKS cluster"
  type        = string
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to use"
  type        = string
  default     = null  # Use latest supported version
}

variable "node_pool_name" {
  description = "The name of the default node pool"
  type        = string
  default     = "default"
}

variable "node_count" {
  description = "The initial number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "The size of the virtual machines in the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "network_plugin" {
  description = "The network plugin to use"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "The network policy to use"
  type        = string
  default     = "azure"
}

variable "enable_auto_scaling" {
  description = "Enable node pool autoscaling"
  type        = bool
  default     = false
}

variable "min_node_count" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 3
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB for nodes"
  type        = number
  default     = 50
}

variable "identity_type" {
  description = "The type of identity used for the AKS cluster"
  type        = string
  default     = "SystemAssigned"
}

variable "acr_id" {
  description = "The Azure Container Registry ID for granting pull permissions"
  type        = string
}

variable "acr_policy" {
  description = "The Azure Container Registry policy for granting pull permissions"
  type        = string
  default     = "AcrPull"
}