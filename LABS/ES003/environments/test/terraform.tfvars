environment = "test"
location    = "westeurope"
vm_size     = "Standard_D2s_v5"

admin_username      = "azureadmin"
ssh_public_key_path = "~/.ssh/id_ed25519.pub"
ssh_allowed_cidr    = "203.0.113.10/32"

vnet_address_space    = ["10.30.0.0/16"]
subnet_address_prefix = "10.30.1.0/24"

os_disk_size_gb = 64

tags = {
  CostCenter  = "IT-TEST"
  Owner       = "QA"
  Criticality = "Medium"
}