locals {
  partition = "/Common"
  is_http   = var.monitor_parent == "/Common/http"
}

# ---------------------------------------------------------------- Network
resource "bigip_net_vlan" "data" {
  name = var.vlan_name
  tag  = var.vlan_tag

  interfaces {
    vlanport = var.vlan_interface
    tagged   = false
  }
}

resource "bigip_net_selfip" "data" {
  name          = var.selfip_name
  ip            = var.selfip_cidr
  vlan          = var.vlan_name
  traffic_group = "traffic-group-local-only"
  port_lockdown = ["none"]

  depends_on = [bigip_net_vlan.data]
}

# ---------------------------------------------------------------- Certificate
resource "tls_private_key" "vip" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "vip" {
  private_key_pem       = tls_private_key.vip.private_key_pem
  validity_period_hours = var.certificate_validity_hours

  subject {
    common_name = var.certificate_common_name
  }

  dns_names = [var.certificate_common_name]

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "bigip_ssl_key" "vip" {
  name      = "${var.app_name}.key"
  partition = "Common"
  content   = tls_private_key.vip.private_key_pem
}

resource "bigip_ssl_certificate" "vip" {
  name      = "${var.app_name}.crt"
  partition = "Common"
  content   = tls_self_signed_cert.vip.cert_pem

  depends_on = [bigip_ssl_key.vip]
}

resource "bigip_ltm_profile_client_ssl" "vip" {
  name          = "${local.partition}/${var.app_name}-clientssl"
  defaults_from = "/Common/clientssl"

  cert_key_chain {
    name = "default"
    cert = "${local.partition}/${bigip_ssl_certificate.vip.name}"
    key  = "${local.partition}/${bigip_ssl_key.vip.name}"
  }
}

# ---------------------------------------------------------------- Pool
resource "bigip_ltm_monitor" "health" {
  name     = "${local.partition}/${var.app_name}-monitor"
  parent   = var.monitor_parent
  interval = 5
  timeout  = 16
  send     = local.is_http ? var.monitor_send : null
  receive  = local.is_http ? var.monitor_receive : null
}

resource "bigip_ltm_node" "member" {
  for_each = var.pool_members

  name    = "${local.partition}/${each.key}"
  address = each.value

  depends_on = [bigip_net_selfip.data]
}

resource "bigip_ltm_pool" "app" {
  name                = "${local.partition}/${var.app_name}-pool"
  load_balancing_mode = var.pool_lb_method
  monitors            = [bigip_ltm_monitor.health.name]
  allow_snat          = "yes"
  allow_nat           = "yes"
}

resource "bigip_ltm_pool_attachment" "member" {
  for_each = bigip_ltm_node.member

  pool = bigip_ltm_pool.app.name
  node = "${each.value.name}:${var.pool_member_port}"
}

# ---------------------------------------------------------------- Virtual server
resource "bigip_ltm_virtual_server" "https" {
  name                       = "${local.partition}/${var.app_name}-vs-https"
  description                = "HTTPS VIP (TLS offload) - managed by Terraform"
  destination                = var.vip_address
  port                       = var.vip_port
  mask                       = "255.255.255.255"
  ip_protocol                = "tcp"
  pool                       = bigip_ltm_pool.app.name
  profiles                   = ["/Common/tcp", "/Common/http"]
  client_profiles            = [bigip_ltm_profile_client_ssl.vip.name]
  source_address_translation = "automap"
  translate_address          = "enabled"
  translate_port             = "enabled"

  depends_on = [bigip_ltm_pool_attachment.member]
}
