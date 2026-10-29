provider "bigip" {
  address  = var.bigip_address
  port     = var.bigip_port
  username = var.bigip_username
  password = var.bigip_password

  validate_certs_disable = var.bigip_validate_certs_disable
}
