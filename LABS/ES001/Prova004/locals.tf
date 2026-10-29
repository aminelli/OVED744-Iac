locals {
  # Prefisso di naming riutilizzato ovunque
  name_prefix = "${var.project}-${var.env}"

  # Tag comuni a tutte le risorse
  common_tags = {
    project     = var.project
    environment = var.env
    managed_by  = "terraform"
  }

  # Condizionale: dimensione diversa per ambiente
  vm_size = var.env == "prod" ? "Standard_D4s_v5" : "Standard_B2s"

  # Flag derivato
  is_prod = var.env == "prod"
}