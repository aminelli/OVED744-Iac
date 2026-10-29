resource "proxmox_virtual_environment_vm" "bigip" {
  name      = var.vm_name
  node_name = var.proxmox_node_name
  vm_id     = var.vm_id
  tags      = var.vm_tags

  description = "F5 BIG-IP VE (LTM) - managed by Terraform"

  bios          = "seabios"
  scsi_hardware = "virtio-scsi-pci"
  on_boot       = true
  started       = true

  # No QEMU guest agent inside BIG-IP: force-stop on destroy.
  agent {
    enabled = false
  }
  stop_on_destroy = true

  operating_system {
    type = "l26"
  }

  cpu {
    cores = var.vm_cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.vm_memory_mb
  }

  # The disk size is taken from the qcow2 image (no "size" override).
  disk {
    datastore_id = var.disk_datastore_id
    import_from  = "${var.image_datastore_id}:import/${var.image_file_name}"
    interface    = var.disk_interface
  }

  boot_order = [var.disk_interface]

  dynamic "network_device" {
    for_each = var.network_interfaces
    content {
      bridge      = var.network_bridge
      model       = "virtio"
      mac_address = network_device.value.mac_address
      vlan_id     = var.network_vlan_id
    }
  }

  # BIG-IP prints its console on the serial port too.
  serial_device {}
}
