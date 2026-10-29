variable "service_names" {
  type = set(string)

  default = ["frontend", "backend"]
}

variable "service_passwords" {
  type      = map(string)
  sensitive = true
}

resource "terraform_data" "service" {
  for_each = var.service_names

  input = {
    name = each.key
  }
}

resource "terraform_data" "service2" {
  for_each = var.service_names

  input = {
    name     = each.key
    password = var.service_passwords[each.key]
  }
}