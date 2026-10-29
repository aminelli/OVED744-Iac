resource "azurerm_key_vault" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  rbac_authorization_enabled = true

  soft_delete_retention_days = 90
  purge_protection_enabled   = true

  # Per questo esempio didattico.
  # In produzione definire rete privata e DNS
  # prima di disabilitare l'accesso pubblico.
  public_network_access_enabled = true

  tags = var.tags
}