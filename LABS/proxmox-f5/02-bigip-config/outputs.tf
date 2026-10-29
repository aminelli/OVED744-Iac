output "vip_url" {
  description = "HTTPS VIP URL."
  value       = "https://${var.vip_address}:${var.vip_port}/"
}

output "pool_name" {
  description = "Pool full path."
  value       = bigip_ltm_pool.app.name
}

output "pool_members" {
  description = "Pool members (ip:port)."
  value       = [for k, ip in var.pool_members : "${ip}:${var.pool_member_port}"]
}

output "certificate_pem" {
  description = "Self-signed certificate installed on the VIP."
  value       = tls_self_signed_cert.vip.cert_pem
}
