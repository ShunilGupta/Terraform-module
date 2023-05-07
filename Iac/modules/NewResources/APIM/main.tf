resource "azurerm_api_management" "apim"{
    name = var.apim_name
    location = var.location
    resource_group_name = var.rg-name
    publisher_name = "publisher"
    publisher_email = "Sunil_Gupta1@epam.com"
    sku_name = "Developer_1"
}