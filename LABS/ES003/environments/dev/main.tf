locals {
  project_name = "app"

  resource_prefix = "${local.project_name}-${var.environment}"

  common_tags = merge(
    var.tags,
    {
      Environment = upper(var.environment)
      ManagedBy   = "Terraform"
      Project     = local.project_name
    }
  )
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_prefix}"
  location = var.location

  tags = local.common_tags
}

module "vm_linux" {
  source = "../../modules/vm_linux"

  resource_prefix       = local.resource_prefix
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  vm_size               = var.vm_size
  admin_username        = var.admin_username
  ssh_public_key_path   = var.ssh_public_key_path
  ssh_allowed_cidr      = var.ssh_allowed_cidr
  vnet_address_space    = var.vnet_address_space
  subnet_address_prefix = var.subnet_address_prefix
  os_disk_size_gb       = var.os_disk_size_gb
  tags                  = local.common_tags
}