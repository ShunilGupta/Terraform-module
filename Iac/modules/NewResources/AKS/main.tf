resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  kubernetes_version  = var.kubernetes_version
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = var.aks_name
  node_resource_group = var.node_resource_group

  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = "Standard_DS2_v2"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = false
    vnet_subnet_id        = var.vnet_subnet_id
    node_labels           = var.default_node_pool_labels
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure" # azure (CNI)
  }
}

resource "azurerm_role_assignment" "aks_acr" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}