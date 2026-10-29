variable "bigip_address" {
  description = "BIG-IP management IP or FQDN."
  type        = string
}

variable "bigip_port" {
  description = "BIG-IP management HTTPS port."
  type        = number
  default     = 443
}

variable "bigip_username" {
  description = "BIG-IP admin user for the iControl REST API."
  type        = string
  default     = "admin"
}

variable "bigip_password" {
  description = "BIG-IP admin password (set during the bootstrap phase)."
  type        = string
  sensitive   = true
}

variable "bigip_validate_certs_disable" {
  description = "Disable TLS validation of the BIG-IP management certificate (self-signed by default)."
  type        = bool
  default     = true
}

# ---- Data plane network ----
variable "vlan_name" {
  description = "VLAN name (partition-qualified)."
  type        = string
  default     = "/Common/vlan_data"
}

variable "vlan_interface" {
  description = "BIG-IP interface bound to the VLAN. 1.1 = second VM NIC."
  type        = string
  default     = "1.1"
}

variable "vlan_tag" {
  description = "Optional 802.1Q tag. null = BIG-IP assigns it automatically; the interface stays untagged."
  type        = number
  default     = null
}

variable "selfip_name" {
  description = "Self IP name (partition-qualified)."
  type        = string
  default     = "/Common/selfip_data"
}

variable "selfip_cidr" {
  description = "Self IP in CIDR notation."
  type        = string
  default     = "192.168.10.51/24"
}

# ---- Application ----
variable "app_name" {
  description = "Application name, used as prefix of every LTM object."
  type        = string
  default     = "app-web"
}

variable "vip_address" {
  description = "Virtual server IP address."
  type        = string
  default     = "192.168.10.60"
}

variable "vip_port" {
  description = "Virtual server HTTPS port."
  type        = number
  default     = 443
}

variable "pool_members" {
  description = "Pool members: map name => IP address."
  type        = map(string)
  default = {
    "web-01" = "192.168.10.71"
    "web-02" = "192.168.10.72"
  }
}

variable "pool_member_port" {
  description = "Backend service port (HTTP: TLS is terminated on the BIG-IP)."
  type        = number
  default     = 80
}

variable "pool_lb_method" {
  description = "Pool load balancing method."
  type        = string
  default     = "round-robin"
}

variable "monitor_parent" {
  description = "Parent monitor for the health check (/Common/tcp or /Common/http)."
  type        = string
  default     = "/Common/tcp"
}

variable "monitor_send" {
  description = "Request string sent by the monitor (only for /Common/http)."
  type        = string
  default     = "GET / HTTP/1.0\\r\\n\\r\\n"
}

variable "monitor_receive" {
  description = "Expected response regex (only for /Common/http)."
  type        = string
  default     = "^HTTP/1\\.[01] [23][0-9][0-9]"
}

# ---- Certificate ----
variable "certificate_common_name" {
  description = "CN / SAN DNS name of the self-signed certificate."
  type        = string
  default     = "app.lab.local"
}

variable "certificate_validity_hours" {
  description = "Self-signed certificate validity in hours."
  type        = number
  default     = 8760
}
