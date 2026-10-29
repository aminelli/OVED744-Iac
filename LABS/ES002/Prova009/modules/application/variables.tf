variable "name" {
  type = string
}

variable "service_plan_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "integration_subnet_id" {
  type = string
}

variable "key_vault_uri" {
  type = string
}

variable "sql_fqdn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}