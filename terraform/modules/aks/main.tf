###############################################################################
# 1. AKS Cluster (azurerm_kubernetes_cluster) - AzureRM 4.x
###############################################################################

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.name_prefix}AKS"         # e.g., "collettehealthprodAKS"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.name_prefix}AKS"

  default_node_pool {
    name       = "system"
    vm_size    = var.system_vm_size                  # Default: Standard_B2s
    node_count = var.system_node_count               # Default: 1
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"                    # Must be lowercase
    outbound_type     = "loadBalancer"
  }
}

###############################################################################
# 2. Spot Node Pool (azurerm_kubernetes_cluster_node_pool) - AzureRM 4.x
###############################################################################

resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  name                  = "spot"
  vm_size               = var.spot_vm_size              # Default: Standard_D4as_v5
  os_type               = "Linux"
  mode                  = "User"

  min_count   = 0
  max_count   = var.agent_pool_spot_max_count          # Default: 2
  priority    = "Spot"
  eviction_policy = "Delete"

  node_taints = ["CriticalAddonsOnly=true:NoSchedule"]

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

###############################################################################
# 3. Role Assignment: allow AKS to pull images from ACR
###############################################################################

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
