variable "location" {
  type    = string
  default = "westeurope"
}

variable "storage_account_name" {
  description = "Nome globalmente univoco dello Storage Account"
  type        = string

  validation {
    condition = (
      length(var.storage_account_name) >= 3 &&
      length(var.storage_account_name) <= 24 &&
      can(regex("^[a-z0-9]+$", var.storage_account_name))
    )

    error_message = "Usare 3-24 caratteri alfanumerici minuscoli."
  }
}