locals {
  servers = {
    frontend = {
      instance_type = "t3.small"
    }

    backend = {
      instance_type = "t3.medium"
    }

    batch = {
      instance_type = "t3.large"
    }
  }
}

module "server" {
  source   = "./modules/web-server"
  for_each = local.servers

  name          = each.key
  instance_type = each.value.instance_type
}

