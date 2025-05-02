output "cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks-cluster.id
}

output "cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks-cluster.name
}

output "kube_config" {
  description = "The Kubernetes configuration for the cluster"
  value       = azurerm_kubernetes_cluster.aks-cluster.kube_config_raw
  sensitive   = true
}

output "host" {
  description = "The Kubernetes cluster server host"
  value       = azurerm_kubernetes_cluster.aks-cluster.kube_config[0].host
  sensitive   = true
}

output "client_certificate" {
  description = "The client certificate for authentication"
  value       = azurerm_kubernetes_cluster.aks-cluster.kube_config[0].client_certificate
  sensitive   = true
}

output "client_key" {
  description = "The client key for authentication"
  value       = azurerm_kubernetes_cluster.aks-cluster.kube_config[0].client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate"
  value       = azurerm_kubernetes_cluster.aks-cluster.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "kubelet_identity" {
  description = "The identity of the kubelet"
  value       = azurerm_kubernetes_cluster.aks-cluster.kubelet_identity
}
