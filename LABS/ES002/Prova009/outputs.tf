output "resource_group_name" {
  value = azurerm_resource_group.platform.name
}

output "web_app_url" {
  value = "https://${module.application.default_hostname}"
}

output "sql_server_fqdn" {
  value = module.database.sql_fqdn
}

output "key_vault_uri" {
  value = module.security.key_vault_uri
}

output "log_analytics_workspace_id" {
  value = module.monitoring.workspace_id
}