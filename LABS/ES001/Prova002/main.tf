# DIPENDENZE IMPLICITAMENTE GESTITE DA TERRAFORM

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
  name     = "rg-terraform-demo"
  location = "westeurope"
}

resource "azurerm_storage_account" "demo" {
  name                     = "stterraformdemo123456"
  resource_group_name      = azurerm_resource_group.demo.name
  location                 = azurerm_resource_group.demo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "demo" {
  name                  = "documenti"
  storage_account_id    = azurerm_storage_account.demo.id
  container_access_type = "private"
}
