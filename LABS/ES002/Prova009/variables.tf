variable "subscription_id" {
  description = "ID della subscription Azure"
  type        = string
}

variable "project" {
  description = "Identificativo del progetto"
  type        = string
  default     = "webplatform"
}

variable "environment" {
  description = "Ambiente di deployment"
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "L'ambiente deve essere dev, test oppure prod."
  }
}

variable "location" {
  description = "Regione Azure"
  type        = string
  default     = "westeurope"
}

variable "sql_admin_login" {
  description = "Login amministrativo SQL"
  type        = string
  sensitive   = true
}

variable "sql_admin_password" {
  description = "Password amministrativa SQL"
  type        = string
  sensitive   = true
}