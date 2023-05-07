output key-vault-name {
    value = azurerm_key_vault.akv.name
    description = "The Name of the Azure Key vault"
}
output key-vault-id {
    value = azurerm_key_vault.akv.id
    description = "The id of Azure Key vault"
}
