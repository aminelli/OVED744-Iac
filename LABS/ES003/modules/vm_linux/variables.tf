variable "resource_prefix" {
  description = "Prefisso dei nomi delle risorse"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group di destinazione"
  type        = string
}

variable "location" {
  description = "Regione Azure"
  type        = string
}

variable "vm_size" {
  description = "SKU della VM"
  type        = string
}

variable "admin_username" {
  description = "Username amministrativo Linux"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Percorso della chiave SSH pubblica"
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
    error_message = "La dimensione del disco deve essere tra 30 e 2048 GB."
  }
}

variable "tags" {
  description = "Tag comuni delle risorse"
  type        = map(string)
  default     = {}
}