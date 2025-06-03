# File: modules/aks/outputs.tf

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "kubelet_identity_id" {
  description = "Object ID of the AKS cluster’s kubelet identity (used for ACR pull)"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "aks_kube_config_raw" {
  description = "Raw, base64-encoded kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
  sensitive   = true
}

output "aks_cluster_resource_id" {
  description = "Resource ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}
