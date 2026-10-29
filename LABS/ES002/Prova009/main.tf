locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "platform" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

module "monitoring" {
  source = "./modules/monitoring"

  name                = "law-${local.name_prefix}"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  tags                = local.common_tags
}

module "network" {
  source = "./modules/network"

  name                = "vnet-${local.name_prefix}"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  address_space       = ["10.20.0.0/16"]

  tags = local.common_tags
}

module "security" {
  source = "./modules/security"

  name                = "kv-${var.project}-${var.environment}"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.common_tags
}

module "database" {
  source = "./modules/database"

  name                = "sql-${local.name_prefix}"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  administrator_login    = var.sql_admin_login
  administrator_password = var.sql_admin_password

  vnet_id                    = module.network.vnet_id
  private_endpoint_subnet_id = module.network.private_endpoint_subnet_id
  log_analytics_workspace_id = module.monitoring.workspace_id

  tags = local.common_tags
}

module "application" {
  source = "./modules/application"

  name                = "app-${local.name_prefix}"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  service_plan_name     = "plan-${local.name_prefix}"
  integration_subnet_id = module.network.app_subnet_id

  # key_vault_id = module.security.key_vault_id
  key_vault_uri = module.security.key_vault_uri
  sql_fqdn      = module.database.sql_fqdn

  tags = local.common_tags
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "app_key_vault_secret" {
  scope                = module.security.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.application.principal_id
  principal_type       = "ServicePrincipal"
}
