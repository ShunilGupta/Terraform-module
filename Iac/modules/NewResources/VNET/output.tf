output "vnet_id" {
    value = azurerm_virtual_network.vnet.id
    description = "Vnet id"
}

output vnet_name {
    value = azurerm_virtual_network.vnet.name
    description = "The Name of the Vnet"
}