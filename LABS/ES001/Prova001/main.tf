terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "demo" {
  name     = "rg-iac-demo"
  location = "Italy North"

  tags = {
    environment = "development"
    managed_by  = "terraform"
  }
}

output "resource_group_id" {
  value = azurerm_resource_group.demo.id
}