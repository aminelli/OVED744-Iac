variable "proxmox_endpoint" {
  description = "Proxmox VE API URL, e.g. https://pve.example.local:8006/"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token in the form 'user@realm!tokenid=secret'."
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS verification of the Proxmox API (self-signed certificate)."
  type        = bool
  default     = true
}

variable "proxmox_ssh_username" {
  description = "OS user used by the provider for SSH to the Proxmox node."
  type        = string
  default     = "root"
}

variable "proxmox_ssh_agent" {
  description = "Use the local SSH agent (ssh-agent / Pageant / OpenSSH agent on Windows) to authenticate."
  type        = bool
  default     = true
}

variable "proxmox_node_name" {
  description = "Name of the Proxmox node where the VM is created."
  type        = string
  default     = "pve"
}

variable "vm_id" {
  description = "Proxmox VMID of the BIG-IP VM."
  type        = number
  default     = 9100
}

variable "vm_name" {
  description = "VM name (must be a valid DNS name)."
  type        = string
  default     = "bigip-ltm-01"
}

variable "vm_tags" {
  description = "Proxmox tags applied to the VM."
  type        = list(string)
  default     = ["terraform", "f5", "bigip"]
}

variable "vm_cpu_cores" {
  description = "vCPU count. BIG-IP VE LTM: 4 vCPU recommended (check the F5 VE sizing guide for your license)."
  type        = number
  default     = 4
}

variable "vm_memory_mb" {
  description = "RAM in MiB. 8192 is a safe value for LTM-only provisioning."
  type        = number
  default     = 8192
}

variable "image_datastore_id" {
  description = "Proxmox datastore (directory type) with the 'Import' content type enabled, holding the qcow2 image."
  type        = string
  default     = "local"
}

variable "image_file_name" {
  description = "File name of the BIG-IP qcow2 (already unzipped) inside <datastore>/import/. Must end with .qcow2."
  type        = string
  default     = "BIGIP-17.1.2.ALL.qcow2"
}

variable "disk_datastore_id" {
  description = "Datastore where the VM disk is created."
  type        = string
  default     = "local-lvm"
}

variable "disk_interface" {
  description = "Disk bus/slot. Keep scsi0 unless the F5 image documentation for your build says otherwise."
  type        = string
  default     = "scsi0"
}

variable "network_bridge" {
  description = "Proxmox bridge used by all the VM NICs."
  type        = string
  default     = "vmbr0"
}

variable "network_vlan_id" {
  description = "Optional VLAN tag applied at Proxmox level to all NICs (null = untagged)."
  type        = number
  default     = null
}

# NIC 0 = BIG-IP management (mgmt/eth0). NIC 1 = first data-plane interface (BIG-IP interface 1.1).
# Fixed MAC addresses allow a DHCP reservation, so the management IP is predictable.
variable "network_interfaces" {
  description = "Ordered list of VM NICs. First = management, second = data plane (1.1)."
  type = list(object({
    mac_address = string
  }))
  default = [
    { mac_address = "BC:24:11:F5:00:01" }, # management
    { mac_address = "BC:24:11:F5:00:02" }, # data plane 1.1
  ]
}
