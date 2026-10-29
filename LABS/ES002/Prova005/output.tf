output "nsg_rule_names" {
  value = [for r in azurerm_network_security_group.app.security_rule : r.name]
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}