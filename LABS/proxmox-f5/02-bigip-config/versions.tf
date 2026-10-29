terraform {
  required_version = ">= 1.6.0"

  required_providers {
    bigip = {
      source  = "F5Networks/bigip"
      version = "~> 1.29"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
