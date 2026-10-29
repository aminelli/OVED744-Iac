variable "environment" {
  description = "Ambiente di deployment"
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "L'ambiente deve essere dev, test o prod."
  }
}

variable "location" {
  description = "Regione Azure"
  type        = string
  default     = "westeurope"
}

variable "vm_size" {
  description = "SKU della VM"
  type        = string
}

variable "admin_username" {
  description = "Username Linux"
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key_path" {
  description = "Percorso della chiave pubblica SSH"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR autorizzato per SSH"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "Il CIDR SSH non è valido."
  }
}

variable "vnet_address_space" {
  description = "Spazio di indirizzamento della VNet"
  type        = list(string)
}

variable "subnet_address_prefix" {
  description = "CIDR della subnet"
  type        = string
}

variable "os_disk_size_gb" {
  description = "Dimensione del disco OS"
  type        = number

  validation {
    condition     = var.os_disk_size_gb >= 30 && var.os_disk_size_gb <= 2048
    error_message = "Il disco deve avere almeno 30 GB."
  }
}

variable "tags" {
  description = "Tag specifici dell'ambiente"
  type        = map(string)
  default     = {}
}