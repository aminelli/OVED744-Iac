output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vm_id" {
  value = module.vm_linux.vm_id
}

output "vm_name" {
  value = module.vm_linux.vm_name
}

output "vm_private_ip" {
  value = module.vm_linux.private_ip
}

output "vm_public_ip" {
  value = module.vm_linux.public_ip
}