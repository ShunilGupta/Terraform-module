resource "azurerm_key_vault_secret" "AKV_SECRET" {
  name         = var.akv_secret_name
  value        = var.akv_secret_value
  key_vault_id = var.akv_id
}