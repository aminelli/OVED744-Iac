output "vm_id" {
  description = "ID della VM"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_name" {
  description = "Nome della VM"
  value       = azurerm_linux_virtual_machine.main.name
}

output "private_ip" {
  description = "Indirizzo IP privato"
  value       = azurerm_network_interface.main.private_ip_address
}

output "public_ip" {
  description = "Indirizzo IP pubblico"
  value       = azurerm_public_ip.main.ip_address
}

output "principal_id" {
  description = "ID della managed identity"
  value       = azurerm_linux_virtual_machine.main.identity[0].principal_id
}