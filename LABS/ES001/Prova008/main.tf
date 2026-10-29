variable "environment" {
  type    = string
  description = "Ambiente di distribuzione"

  validation {
    condition = contains(
      ["dev", "stg", "prod"],
      var.environment
    )

    error_message = "L'ambiente deve essere dev, stg o prod."
  }

}

variable "tech" {
  type    = string
  description = "Ambiente di distribuzione"

  validation {
    condition = contains(
      ["vmware", "proxmox", "kube", "docker"],
      var.tech
    )

    error_message = "La tecnologia deve essere vmware, proxmox, kube o docker."
  }
}

resource "terraform_data" "example" {
    input = var.environment    
}

resource "terraform_data" "example_tech" {
    input = var.tech    
}

