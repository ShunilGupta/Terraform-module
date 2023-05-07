resource "azurerm_kubernetes_cluster_node_pool" "user" {
  kubernetes_cluster_id = var.kubernetes_cluster_id
  node_count            = 2
  mode                  = "User"
  name                  = "noodpoollog"
  os_disk_size_gb       = 128
  vm_size               = "Standard_DS2_v2"
  vnet_subnet_id        = var.vnet_subnet_id
  node_labels           = var.node_pool_labels
}