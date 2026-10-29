output "storage_account_id" {
  description = "ID dello storage account creato."
  value       = azurerm_storage_account.this.id
}