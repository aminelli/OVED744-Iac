output "vm_id" {
  description = "Proxmox VMID."
  value       = proxmox_virtual_environment_vm.bigip.vm_id
}

output "vm_name" {
  description = "VM name."
  value       = proxmox_virtual_environment_vm.bigip.name
}

output "management_mac_address" {
  description = "MAC of the management NIC: use it for the DHCP reservation."
  value       = var.network_interfaces[0].mac_address
}
