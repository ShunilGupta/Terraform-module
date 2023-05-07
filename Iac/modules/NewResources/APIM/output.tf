output "apim_id" {
    value = azurerm_api_management.apim.gateway_url
    description = "ACR id"
}

output apimname {
    value = azurerm_api_management.apim.name
    description = "The Name of the APIM"
}