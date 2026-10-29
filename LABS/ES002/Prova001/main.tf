
variable "applications" {
  type = list(
    object(
        {
            name          = string
            instance_type = string
            enabled       = bool
        }
    )
  )
}


locals {
  enabled_applications = {
    for app in var.applications :
    app.name => app
    if app.enabled
  }
}

resource "aws_instance" "app" {
  for_each = local.enabled_applications

  ami           = 1
  instance_type = each.value.instance_type

  tags = {
    Name = each.key
  }
}

#######

variable "vpcs" {
  type = map(object({
    cidr_block = string
  }))
}

resource "aws_vpc" "network" {
  for_each = var.vpcs

  cidr_block = each.value.cidr_block
}

resource "aws_internet_gateway" "network" {
  for_each = aws_vpc.network

  vpc_id = each.value.id
}