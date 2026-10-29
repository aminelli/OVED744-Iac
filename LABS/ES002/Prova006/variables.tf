variable "location" {
  type    = string
  default = "westeurope"
}

variable "resource_group_name" {
  type    = string
  default = "rg-storage-demo"
}

variable "tags" {
  type = map(string)
  default = {
    environment = "demo"
    managed_by  = "terraform"
  }
}

# --- Identity opzionale: null = nessun blocco identity ---
variable "identity_type" {
  type    = string
  default = "SystemAssigned"
  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Valore non valido per identity_type."
  }
}

variable "identity_ids" {
  description = "ID delle user-assigned identity (solo se il tipo le prevede)"
  type        = list(string)
  default     = []
}

# --- Network rules opzionali ---
variable "network_rules" {
  description = "Se null, nessuna restrizione di rete viene applicata"
  type = object({
    default_action = optional(string, "Deny")
    ip_rules       = optional(list(string), [])
    bypass         = optional(list(string), ["AzureServices"])
    subnet_ids     = optional(list(string), [])
  })
  default = {
    ip_rules = ["203.0.113.10", "198.51.100.0/24"]
  }
}

# --- CORS: lista di regole (può essere vuota) ---
variable "cors_rules" {
  type = list(object({
    allowed_origins    = list(string)
    allowed_methods    = list(string)
    allowed_headers    = optional(list(string), ["*"])
    exposed_headers    = optional(list(string), ["*"])
    max_age_in_seconds = optional(number, 3600)
  }))
  default = [
    {
      allowed_origins = ["https://app.example.com"]
      allowed_methods = ["GET", "HEAD"]
    }
  ]
}

variable "blob_soft_delete_days" {
  description = "Giorni di soft delete per i blob; 0 = disabilitato"
  type        = number
  default     = 14
}

# --- Container da creare ---
variable "containers" {
  type = map(object({
    access_type = optional(string, "private")
    metadata    = optional(map(string), {})
  }))
  default = {
    logs    = {}
    backups = { metadata = { retention = "long" } }
    exports = {}
  }
}

# --- Regole di lifecycle management ---
variable "lifecycle_rules" {
  type = map(object({
    enabled                    = optional(bool, true)
    prefix_match               = list(string)
    tier_to_cool_after_days    = optional(number)
    tier_to_archive_after_days = optional(number)
    delete_after_days          = optional(number)
    snapshot_delete_after_days = optional(number)
  }))
  default = {
    logs-retention = {
      prefix_match               = ["logs/"]
      tier_to_cool_after_days    = 30
      delete_after_days          = 365
      snapshot_delete_after_days = 30
    }
    backups-archive = {
      prefix_match               = ["backups/"]
      tier_to_cool_after_days    = 15
      tier_to_archive_after_days = 90
    }
  }
}