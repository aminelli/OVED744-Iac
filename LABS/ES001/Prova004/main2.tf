variable "subnets" {
  type = map(object({
    cidr      = string
    has_nsg   = bool
  }))
  default = {
    app = { cidr = "10.0.1.0/24", has_nsg = true }
    db  = { cidr = "10.0.2.0/24", has_nsg = true }
    gw  = { cidr = "10.0.3.0/24", has_nsg = false }
  }
}

variable "subnets_list" {
  type = list(object({
    name    = string
    cidr    = string
    has_nsg = bool
  }))
  default = [
    { name = "app", cidr = "10.0.1.0/24", has_nsg = true },
    { name = "db",  cidr = "10.0.2.0/24", has_nsg = true },
    { name = "gw",  cidr = "10.0.3.0/24", has_nsg = false },
  ]
}

variable "environmments" {
  type = map(object({
    env_type      = string
    description   = string
  }))
  default = {
    dev      = { env_type = "DEV", description = "dev environment" }
    prod     = { env_type = "PROD", description = "prod environment" }
    staging  = { env_type = "STAGING", description = "staging environment" }
  }
}

locals {
  # Solo le subnet che richiedono un NSG
  subnets_with_nsg = {
    for name, s in var.subnets : name => s if s.has_nsg
    # for key, value in var.subnets : key => value if s.has_nsg == true
  }

  app_ports = [80, 443, 8080]
  
  all_env_codes = [for s in var.environmments : lower(s.env_type)]

  # Lista dei CIDR (utile per regole firewall)
  all_cidrs = [for s in var.subnets : s.cidr]

  # Mappa nome => nome risorsa completo
  subnet_names = {
    for name, s in var.subnets : name => "snet-${local.name_prefix}-${name}"
  }
}

locals {
  base_domain = "etlforma.com"
  fqdn        = "${var.env}.${local.base_domain}"
  app_url     = "https://app.${local.fqdn}"
}

resource "azurerm_network_security_group" "this" {
  for_each = local.subnets_with_nsg

  name                = "nsg-${local.name_prefix}-${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.name_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]

  tags = merge(local.common_tags, {
    role = "network-core"
  })
}