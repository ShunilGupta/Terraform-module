output acr_id {
    value = azurerm_container_registry.ACR.id
    description = "ACR id"
}

output acr_name {
    value = azurerm_container_registry.ACR.name
    description = "The Name of the ACR"
}