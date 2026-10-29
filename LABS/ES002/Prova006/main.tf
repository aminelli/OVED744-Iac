terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
  # subscription_id = "..." oppure variabile d'ambiente ARM_SUBSCRIPTION_ID
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "this" {
  name                            = "stdemo${random_string.suffix.result}"
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  tags                            = var.tags

  # 1) Blocco opzionale: 0 o 1 occorrenza
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []

    content {
      type         = var.identity_type
      identity_ids = contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) ? var.identity_ids : null
    }
  }

  # 2) Blocco opzionale guidato da un oggetto (null = omesso)
  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []

    content {
      default_action             = network_rules.value.default_action
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.subnet_ids
      bypass                     = network_rules.value.bypass
    }
  }

  blob_properties {
    versioning_enabled = true

    # 3) Dynamic annidato: delete_retention_policy solo se i giorni > 0
    dynamic "delete_retention_policy" {
      for_each = var.blob_soft_delete_days > 0 ? [var.blob_soft_delete_days] : []

      content {
        days = delete_retention_policy.value
      }
    }

    # 4) Dynamic annidato: N regole CORS da una lista
    dynamic "cors_rule" {
      for_each = var.cors_rules

      content {
        allowed_origins    = cors_rule.value.allowed_origins
        allowed_methods    = cors_rule.value.allowed_methods
        allowed_headers    = cors_rule.value.allowed_headers
        exposed_headers    = cors_rule.value.exposed_headers
        max_age_in_seconds = cors_rule.value.max_age_in_seconds
      }
    }
  }
}

# ---------------------------------------------------------------
# Container: qui NON serve dynamic, è una risorsa -> for_each
# ---------------------------------------------------------------
resource "azurerm_storage_container" "this" {
  for_each = var.containers

  name                  = each.key
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = each.value.access_type
  metadata              = each.value.metadata
}

# ---------------------------------------------------------------
# Lifecycle management con dynamic "rule" e dynamic "snapshot" annidato
# ---------------------------------------------------------------
resource "azurerm_storage_management_policy" "this" {
  count              = length(var.lifecycle_rules) > 0 ? 1 : 0
  storage_account_id = azurerm_storage_account.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      name    = rule.key
      enabled = rule.value.enabled

      filters {
        blob_types   = ["blockBlob"]
        prefix_match = rule.value.prefix_match
      }

      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than    = rule.value.tier_to_cool_after_days
          tier_to_archive_after_days_since_modification_greater_than = rule.value.tier_to_archive_after_days
          delete_after_days_since_modification_greater_than          = rule.value.delete_after_days
        }

        # Blocco annidato presente solo se è definita la retention degli snapshot
        dynamic "snapshot" {
          for_each = rule.value.snapshot_delete_after_days != null ? [rule.value.snapshot_delete_after_days] : []

          content {
            delete_after_days_since_creation_greater_than = snapshot.value
          }
        }
      }
    }
  }
}