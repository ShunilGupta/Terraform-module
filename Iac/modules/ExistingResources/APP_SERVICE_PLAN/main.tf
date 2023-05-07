data "azurerm_app_service" "example" {
  name                = var.app_service_plan
  resource_group_name = var.rg_name
}
