output rg-name {
    value = azurerm_resource_group.RG.name
    description = "The Name of the RG"
}
output locations {
    value = azurerm_resource_group.RG.location
    description = "The region of the RG"
}