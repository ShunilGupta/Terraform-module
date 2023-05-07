output "storage_account_tier" {
  value = data.azurerm_storage_account.example.account_tier
}

output "storage_account_name" {
  value = data.azurerm_storage_account.example.name
}

output "storage_account_access_key" {
  value = data.azurerm_storage_account.example.primary_access_key
}