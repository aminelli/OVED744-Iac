locals {
  environments = ["development", "staging", "production"]

  uppercase_environments = [
    for env in local.environments : upper(env)
  ]

  uppercase_environments_2 = {
    for env in local.environments : env => upper(env)
  }
}

locals {
  service_ports = {
    api    = 8080
    worker = 9090
    admin  = 8443
  }

  service_names = {
    for name, port in local.service_ports : name => upper(name)
  }
}


locals {
  ports = [80, 443, 8080]

  doubled_ports = [
    for port in local.ports : port * 2
  ]
}

locals {
  services = ["api", "worker", "admin"]

  indexed_services = [
    for index, service in local.services : "${index}: ${service}"
  ]
}


locals {
  vm_sizes = {
    development = "Standard_B2s"
    staging     = "Standard_D2s_v5"
    production  = "Standard_D4s_v5"
  }

  descriptions = [
    for env, size in local.vm_sizes : "${env}: ${size}"
  ]
}

variable "virtual_machines" {
  type = list(object({
    name = string
    size = string
    zone = number
  }))
}

locals {
  vm_names = [
    for vm in var.virtual_machines : vm.name
  ]

  vm_zones = [
    for vm in var.virtual_machines : vm.zone
  ]

  vm_sizes_list = [
    for vm in var.virtual_machines : vm.size
  ]

  vm_labels = [
    for vm in var.virtual_machines : "${lower(vm.name)}-${vm.zone}"
  ]
}


locals {
  vm_inventory = [
    for vm in var.virtual_machines : {
      id                = vm.name
      machine_size      = vm.size
      availability_zone = vm.zone
    }
  ]

  production_vms = [
    for vm in var.virtual_machines : vm if vm.size == "Standard_D2s_v5"
  ]
}


locals {
 

  public_services = {
    for name, port in local.service_ports :
    name => port
    if port != 8443
  }

  public_service_names = [
    for name, port in local.service_ports :
    upper(name)
    if port < 9000
  ]


   environment_map = {
    for env in local.environments :
    env => upper(env)
  }

  vm_map = {
    for vm in var.virtual_machines :
    vm.name => vm
  }

}



locals {
  virtual_machines_local = [
    {
      name = "vm-api"
      zone = "zone-1"
    },
    {
      name = "vm-worker"
      zone = "zone-2"
    },
    {
      name = "vm-admin"
      zone = "zone-1"
    }
  ]

   vms_by_zone = {
    for vm in local.virtual_machines_local :
    vm.zone => vm.name...
  }
}


locals {
  services2 = {
    worker = 9090
    api    = 8080
    admin  = 8443
  }

  service_names_2 = [
    for name, port in local.services2 : name
  ]

  unique_names = toset([
    for vm in var.virtual_machines : vm.name
  ])

}


locals {
  environments_complex = {
    development = ["api", "worker"]
    staging     = ["api", "worker", "admin"]
    production  = ["api", "worker", "admin"]
  }

  service_namescomplex = flatten([
    for env, services in local.environments_complex : [
      for service in services :
      "${env}-${service}"
    ]
  ])
}