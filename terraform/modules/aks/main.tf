###############################################################################
# 1. AKS Cluster (System-assigned identity, cost-optimized defaults)
###############################################################################
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.name_prefix}AKS"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.name_prefix}AKS"

  default_node_pool {
    name       = "system"
    vm_size    = var.system_vm_size
    node_count = var.system_node_count
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }


  tags = {
    Environment = var.environment
    CreatedBy   = "terraform"
    Project     = "EmployeeMonitoring"
  }
}

###############################################################################
# 2. Spot Node Pool (User pool, cost-optimized scaling)
###############################################################################
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  name                  = "spot"
  vm_size               = var.spot_vm_size
  os_type               = "Linux"
  mode                  = "User"

  auto_scaling_enabled = true
  min_count            = 0
  max_count            = var.aks_spot_max_count

  priority        = "Spot"
  eviction_policy = "Delete"
  node_taints     = ["CriticalAddonsOnly=true:NoSchedule"]

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}
/*
###############################################################################
# 3. Role Assignment: Allow AKS kubelet identity to pull images from ACR
###############################################################################
resource "azurerm_role_assignment" "aks_acr_pull" {
  count                = var.create_role_assignment ? 1 : 0
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
*/