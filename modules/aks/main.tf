# Create an AKS cluster with specified configuration
resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version # Specify Kubernetes version

  # Enable Web App Routing
  #web_app_routing_enabled = true

  # Configure the default node pool
  default_node_pool {
    name       = var.node_pool_name
    node_count = var.node_count
    vm_size    = var.vm_size
    # Autoscaling configuration (if enabled)
    min_count       = var.enable_auto_scaling ? var.min_node_count : null
    max_count       = var.enable_auto_scaling ? var.max_node_count : null
    os_disk_size_gb = var.os_disk_size_gb
  }

  # Identity configuration for the cluster
  identity {
    type = var.identity_type # Using System Assigned managed identity
  }

  # Network configuration
  network_profile {
    network_plugin = var.network_plugin # Using basic kubenet CNI
    network_policy = var.network_policy # Enable network policies with Calico
  }
}

# Grant AKS access to pull images from ACR
resource "azurerm_role_assignment" "aks-acr-pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks-cluster.kubelet_identity[0].object_id
  role_definition_name             = var.acr_policy
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}

# Configure local kubectl context
resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${var.rg_name} --name ${azurerm_kubernetes_cluster.aks-cluster.name} --overwrite-existing"
  }

  depends_on = [azurerm_kubernetes_cluster.aks-cluster]
}
