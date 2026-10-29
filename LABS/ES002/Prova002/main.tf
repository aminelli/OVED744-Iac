variable "ami_filters" {
  type = map(string)

  default = {
    web = "web-server"
    api = "api-server"
  }
}

data "aws_ami" "selected" {
  for_each = var.ami_filters

  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = [each.value]
  }
}