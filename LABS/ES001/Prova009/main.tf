variable "environment" {
  description = "Ambiente di destinazione"
  type        = string

  validation {
    condition = contains(
      ["dev", "test", "prod"],
      var.environment
    )

    error_message = "L'ambiente deve essere dev, test oppure prod."
  }
}


variable "project_name" {
  description = "Nome identificativo del progetto"
  type        = string

  validation {
    condition = can(regex(
      "^[a-z][a-z0-9-]{1,18}[a-z0-9]$",
      var.project_name
    ))

    error_message = "Il nome deve avere da 3 a 20 caratteri, iniziare con una lettera minuscola e contenere solo lettere minuscole, numeri e trattini. Non può terminare con un trattino."
  }
}



variable "network_cidr" {
  description = "Blocco CIDR della rete"
  type        = string

  validation {
    condition = can(cidrnetmask(var.network_cidr))

    error_message = "Inserire un blocco CIDR IPv4 valido, ad esempio 10.10.0.0/16."
  }

  validation {
    condition = can(cidrnetmask(var.network_cidr)) ? (
      tonumber(split("/", var.network_cidr)[1]) >= 16 &&
      tonumber(split("/", var.network_cidr)[1]) <= 28
    ) : false

    error_message = "Il prefisso CIDR deve essere compreso tra /16 e /28."
  }
}

variable "instance_count" {
  type = number

  validation {
    condition = (
      var.instance_count >= 1 &&
      var.instance_count <= 5 &&
      var.instance_count == floor(var.instance_count)
    )

    error_message = "Il numero di istanze deve essere un intero tra 1 e 5."
  }

  validation {
    condition = (
      var.environment != "dev" ||
      var.instance_count == 1
    )

    error_message = "Nell'ambiente dev è consentita una sola istanza."
  }
}
