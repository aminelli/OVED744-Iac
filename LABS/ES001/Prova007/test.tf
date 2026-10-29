variable "environment" {
  type    = string
  default = "production"

  validation {
    condition = contains(
      ["development", "staging", "production"],
      var.environment
    )

    error_message = "L'ambiente deve essere development, staging o production."
  }
}

locals {
  vm_size = (var.environment == "production" ? "Standard_D4s_v5" : "Standard_B2s")

  vm_size2 = (
    var.environment == "production" ? 
    "Standard_D4s_v5" :
    (var.environment == "staging"    ? "Standard_D2s_v5" :"Standard_B2s")
  )  


  enable_prod = (var.environment == "production" ? true : false)
  # condition_1 ? value_1 : condition_2 ? value_2 : default_value
}

variable "disk_size" {
  type    = number
  default = 128
}

locals {
  disk_tier = var.disk_size >= 100 ? "premium" : "standard"

  use_large_vm = ( var.environment == "production" || var.environment == "staging")
}