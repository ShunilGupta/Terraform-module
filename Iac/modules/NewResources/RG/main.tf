resource "azurerm_resource_group" "RG" {
  name                     = var.rg_name
  location                 = var.location
}