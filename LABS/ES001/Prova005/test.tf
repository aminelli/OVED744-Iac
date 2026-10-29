terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

variable "instance_count" {
  description = "Numero di istanze da creare."
  type        = number
  default     = 2
}

variable "region" {
  description = "Regione cloud di destinazione."
  type        = string
  default     = "westeurope"
}

variable "monitoring_enabled" {
  description = "Abilita il monitoraggio."
  type        = bool
  default     = true
}

locals {
  instance_count = 3
  cpu_threshold  = 0.75
  disk_size_gb   = 128
}

locals {
  total_disk_size = local.disk_size_gb * 2
  threshold_pct   = local.cpu_threshold * 100
}

variable "availability_zones" {
  description = "Zone di disponibilità."
  type        = list(string)

  default = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c",
    "eu-west-1c"
  ]
}

locals {
  primary_zone   = var.availability_zones[0]
  secondary_zone = var.availability_zones[1]
}

locals {
  uppercase_zones = [
    for zone in var.availability_zones : upper(zone)
  ]
}


variable "allowed_ports" {
  description = "Porte autorizzate."
  type        = set(number)

  default = [22, 80, 443, 443]
}

locals {
  unique_ports = toset([22, 80, 443, 443])
}

variable "instance_types" {
  description = "Tipi di istanza per ambiente."
  type        = map(string)

  default = {
    dev  = "t3.micro"
    test = "t3.small"
    prod = "t3.large"
  }
}

variable "environment" {
  description = "Ambiente di destinazione."
  type        = string
  default     = "dev"
}

locals {
  selected_instance_type = var.instance_types[var.environment]
}

variable "server_profile" {
  description = "Profilo del server."
  type        = tuple([string, number, bool])

  default = ["web-server", 443, true]
}

variable "server_profile2" {
  description = "Profilo dei servers."
  type        = list(tuple([string, number, bool]))

  default = [
    ["web-server", 443, true],
    ["api-server", 4443, true],
    ["backend-server", 8443, true]
  ]
}

locals {
  server_name = var.server_profile[0]
  server_port = var.server_profile[1]
  tls_enabled = var.server_profile[2]
}

locals {
  server_name1 = var.server_profile2[1][0]
  server_port1 = var.server_profile2[1][1]
  tls_enabled1 = var.server_profile2[1][2]
}


variable "profiles_type" {
  description = "Tipi di istanza per ambiente."
  type        = map(tuple([string, number, bool]))

  default = {
    web  = ["web-server", 443, true]
    api  = ["api-server", 4443, true]
    back = ["backend-server", 8443, true]
  }
}

variable "virtual_machine" {
  description = "Configurazione della macchina virtuale."

  type = object({
    name         = string
    size         = string
    disk_size_gb = number
    monitoring   = bool
  })

  default = {
    name         = "vm-web-01"
    size         = "Standard_B2s"
    disk_size_gb = 64
    monitoring   = true
  }
}

locals {
  vm_name         = var.virtual_machine.name
  vm_size         = var.virtual_machine.size
  vm_disk_size_gb = var.virtual_machine.disk_size_gb
  vm_monitoring   = var.virtual_machine.monitoring
}



variable "test1" {
  description = "Tipi di istanza per ambiente."
  type        = map(string)

  default = {
    name         = "vm-web-01"
    size         = "Standard_B2s"
    disk_size_gb = 64
    enable       = true
  }
}

variable "test2" {
  description = "Configurazione della macchina virtuale."

  type = object({
    name         = string
    size         = string
    disk_size_gb = number
    enable       = bool
  })

  default = {
    name         = "vm-web-01"
    size         = "Standard_B2s"
    disk_size_gb = 64
    enable       = true
  }
}


variable "test3" {
  description = "Tipi di istanza per ambiente."
  default     = "ciao mondo"
}


variable "virtual_machine2" {
  description = "Configurazione della macchina virtuale."

  type = object({
    name         = string
    size         = string
    disk_size_gb = number
    monitoring   = optional(bool, true)
  })

  default = {
    name         = "vm-web-01"
    size         = "Standard_B2s"
    disk_size_gb = 64
  }
}

locals {
  port_text  = tostring(443)
  port_value = tonumber("443")
  unique_ids = toset(["web", "api", "web"])
}



locals {
  script_shell = <<EOT
        #!/bin/bash
        echo "Hello, World!"
EOT
}


locals {
  test = jsonencode({
    name         = "vm-web-01"
    size         = "Standard_B2s"
    disk_size_gb = 64
    enable       = true
  })


  test2 = <<EOT
{
    "disk_size_gb":64,
    "enable":true,
    "name":"vm-web-01",
    "size":"Standard_B2s"
}
    EOT

  test3 = yamlencode({
    name         = "vm-web-01"
    size         = "Standard_B2s"
    disk_size_gb = 64
    enable       = true
  })
}

locals {
  msg = "Hello, %{if var.virtual_machine.name != ""}${var.virtual_machine.name}%{else}unnamed%{endif}!"
}


variable "ips" {
  description = "Indirizzi IP."
  type        = list(string)

  default = [
    "122.148.40.1",
    "122.148.40.2",
    "122.148.40.3",
    "122.148.40.4"
  ]
}

locals {

  ip_count = length(var.ips)


  ips_list_text = <<EOT
%{for ip in var.ips[*]}
server ${ip}
%{endfor}
EOT

  ips_list_text2 = <<EOT
%{for ip in var.ips[*]~}
server ${ip}
%{endfor~}
EOT

  ips_list_text3 = <<EOT
    %{for ip in var.ips[*]} 
    server ${ip} 
    %{endfor}  
    EOT

}


variable "virtual_machine_3" {
  type = object({
    name   = string
    region = string

    network = object({
      subnet_id  = string
      private_ip = string
    })

    disks = list(object({
      name = string
      size = number
      type = string
    }))
  })

  default = {
    name   = "vm-app-01"
    region = "westeurope"

    network = {
      subnet_id  = "subnet-app"
      private_ip = "10.0.1.10"
    }

    disks = [
      {
        name = "os"
        size = 64
        type = "ssd"
      },
      {
        name = "data"
        size = 128
        type = "ssd"
      }
    ]
  }
}
