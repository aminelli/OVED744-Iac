output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "container_names" {
  value = keys(azurerm_storage_container.this)
}

output "identity_principal_id" {
  description = "Utile per assegnare ruoli RBAC (es. Storage Blob Data Contributor)"
  value       = try(azurerm_storage_account.this.identity[0].principal_id, null)
}