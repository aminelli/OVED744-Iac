

resource "azurerm_resource_group" "main2" {
  name     = "rg-${local.name_prefix}-2"
  location = var.location
  tags     = local.common_tags
  
}


resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "main" {
  # Storage account: solo minuscole e numeri, max 24 caratteri
  name                     = substr(replace("st${local.name_prefix}", "-", ""), 0, 24)
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = local.is_prod ? "GRS" : "LRS"
  tags                     = local.common_tags
}