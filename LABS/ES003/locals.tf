locals {
  project_name = "app"

  common_tags = {
    ManagedBy = "Terraform"
    Project   = local.project_name
  }

  default_location = "westeurope"
}