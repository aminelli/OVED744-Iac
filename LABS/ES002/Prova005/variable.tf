variable "location" {
  type    = string
  default = "westeurope"
}

variable "resource_group_name" {
  type    = string
  default = "rg-dynamic-demo"
}

variable "nsg_rules" {
  description = "Regole di sicurezza del NSG"
  
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = optional(string, "*")
    destination_port_ranges    = list(string)
    source_address_prefix      = string
    destination_address_prefix = optional(string, "*")
  }))

  default = {
    allow-https = {
      priority                = 100
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "Tcp"
      destination_port_ranges = ["443"]
      source_address_prefix   = "Internet"
    }
    allow-ssh-admin = {
      priority                = 110
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "Tcp"
      destination_port_ranges = ["22"]
      source_address_prefix   = "203.0.113.0/24"
    }
    deny-all-inbound = {
      priority                = 4096
      direction               = "Inbound"
      access                  = "Deny"
      protocol                = "*"
      destination_port_ranges = ["*"]
      source_address_prefix   = "*"
    }
  }
}

variable "allowed_ip_rules" {
  description = "IP pubblici autorizzati sulla storage account"
  type        = list(string)
  default     = ["203.0.113.10", "198.51.100.0/24"]
}

variable "enable_network_rules" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {
    environment = "demo"
    managed_by  = "terraform"
  }
}