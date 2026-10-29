provider "azurerm" {
  features {}
}

variable "env" {
  type = string
}

variable "project" {
  type    = string
  default = "demo"
}


variable "location" {
  type    = string
  default = "westeurope"
}
