output subnet-name {
    value = azurerm_subnet.subnet.name
    description = "The Name of the Vnet"
}
output subnet-id {
    value = azurerm_subnet.subnet.id
    description = "The Id of the Vnet"
}