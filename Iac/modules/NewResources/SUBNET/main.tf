resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnetwork_name
  address_prefixes     = var.subnet_address_prefixes

}
