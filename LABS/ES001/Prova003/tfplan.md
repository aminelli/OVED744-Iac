
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  [32m+[0m create[0m

Terraform will perform the following actions:

[1m  # azurerm_resource_group.demo[0m will be created
[0m  [32m+[0m[0m resource "azurerm_resource_group" "demo" {
      [32m+[0m[0m id       = (known after apply)
      [32m+[0m[0m location = "westeurope"
      [32m+[0m[0m name     = "rg-terraform-demo"
    }

[1m  # azurerm_storage_account.demo[0m will be created
[0m  [32m+[0m[0m resource "azurerm_storage_account" "demo" {
      [32m+[0m[0m access_tier                        = (known after apply)
      [32m+[0m[0m account_kind                       = "StorageV2"
      [32m+[0m[0m account_replication_type           = "LRS"
      [32m+[0m[0m account_tier                       = "Standard"
      [32m+[0m[0m allow_nested_items_to_be_public    = true
      [32m+[0m[0m cross_tenant_replication_enabled   = false
      [32m+[0m[0m default_to_oauth_authentication    = false
      [32m+[0m[0m dns_endpoint_type                  = "Standard"
      [32m+[0m[0m https_traffic_only_enabled         = true
      [32m+[0m[0m id                                 = (known after apply)
      [32m+[0m[0m infrastructure_encryption_enabled  = false
      [32m+[0m[0m is_hns_enabled                     = false
      [32m+[0m[0m large_file_share_enabled           = (known after apply)
      [32m+[0m[0m local_user_enabled                 = true
      [32m+[0m[0m location                           = "westeurope"
      [32m+[0m[0m min_tls_version                    = "TLS1_2"
      [32m+[0m[0m name                               = "stterraformdemo123456"
      [32m+[0m[0m nfsv3_enabled                      = false
      [32m+[0m[0m primary_access_key                 = (sensitive value)
      [32m+[0m[0m primary_blob_connection_string     = (sensitive value)
      [32m+[0m[0m primary_blob_endpoint              = (known after apply)
      [32m+[0m[0m primary_blob_host                  = (known after apply)
      [32m+[0m[0m primary_blob_internet_endpoint     = (known after apply)
      [32m+[0m[0m primary_blob_internet_host         = (known after apply)
      [32m+[0m[0m primary_blob_microsoft_endpoint    = (known after apply)
      [32m+[0m[0m primary_blob_microsoft_host        = (known after apply)
      [32m+[0m[0m primary_connection_string          = (sensitive value)
      [32m+[0m[0m primary_dfs_endpoint               = (known after apply)
      [32m+[0m[0m primary_dfs_host                   = (known after apply)
      [32m+[0m[0m primary_dfs_internet_endpoint      = (known after apply)
      [32m+[0m[0m primary_dfs_internet_host          = (known after apply)
      [32m+[0m[0m primary_dfs_microsoft_endpoint     = (known after apply)
      [32m+[0m[0m primary_dfs_microsoft_host         = (known after apply)
      [32m+[0m[0m primary_file_endpoint              = (known after apply)
      [32m+[0m[0m primary_file_host                  = (known after apply)
      [32m+[0m[0m primary_file_internet_endpoint     = (known after apply)
      [32m+[0m[0m primary_file_internet_host         = (known after apply)
      [32m+[0m[0m primary_file_microsoft_endpoint    = (known after apply)
      [32m+[0m[0m primary_file_microsoft_host        = (known after apply)
      [32m+[0m[0m primary_location                   = (known after apply)
      [32m+[0m[0m primary_queue_endpoint             = (known after apply)
      [32m+[0m[0m primary_queue_host                 = (known after apply)
      [32m+[0m[0m primary_queue_microsoft_endpoint   = (known after apply)
      [32m+[0m[0m primary_queue_microsoft_host       = (known after apply)
      [32m+[0m[0m primary_table_endpoint             = (known after apply)
      [32m+[0m[0m primary_table_host                 = (known after apply)
      [32m+[0m[0m primary_table_microsoft_endpoint   = (known after apply)
      [32m+[0m[0m primary_table_microsoft_host       = (known after apply)
      [32m+[0m[0m primary_web_endpoint               = (known after apply)
      [32m+[0m[0m primary_web_host                   = (known after apply)
      [32m+[0m[0m primary_web_internet_endpoint      = (known after apply)
      [32m+[0m[0m primary_web_internet_host          = (known after apply)
      [32m+[0m[0m primary_web_microsoft_endpoint     = (known after apply)
      [32m+[0m[0m primary_web_microsoft_host         = (known after apply)
      [32m+[0m[0m public_network_access_enabled      = true
      [32m+[0m[0m queue_encryption_key_type          = "Service"
      [32m+[0m[0m resource_group_name                = "rg-terraform-demo"
      [32m+[0m[0m secondary_access_key               = (sensitive value)
      [32m+[0m[0m secondary_blob_connection_string   = (sensitive value)
      [32m+[0m[0m secondary_blob_endpoint            = (known after apply)
      [32m+[0m[0m secondary_blob_host                = (known after apply)
      [32m+[0m[0m secondary_blob_internet_endpoint   = (known after apply)
      [32m+[0m[0m secondary_blob_internet_host       = (known after apply)
      [32m+[0m[0m secondary_blob_microsoft_endpoint  = (known after apply)
      [32m+[0m[0m secondary_blob_microsoft_host      = (known after apply)
      [32m+[0m[0m secondary_connection_string        = (sensitive value)
      [32m+[0m[0m secondary_dfs_endpoint             = (known after apply)
      [32m+[0m[0m secondary_dfs_host                 = (known after apply)
      [32m+[0m[0m secondary_dfs_internet_endpoint    = (known after apply)
      [32m+[0m[0m secondary_dfs_internet_host        = (known after apply)
      [32m+[0m[0m secondary_dfs_microsoft_endpoint   = (known after apply)
      [32m+[0m[0m secondary_dfs_microsoft_host       = (known after apply)
      [32m+[0m[0m secondary_file_endpoint            = (known after apply)
      [32m+[0m[0m secondary_file_host                = (known after apply)
      [32m+[0m[0m secondary_file_internet_endpoint   = (known after apply)
      [32m+[0m[0m secondary_file_internet_host       = (known after apply)
      [32m+[0m[0m secondary_file_microsoft_endpoint  = (known after apply)
      [32m+[0m[0m secondary_file_microsoft_host      = (known after apply)
      [32m+[0m[0m secondary_location                 = (known after apply)
      [32m+[0m[0m secondary_queue_endpoint           = (known after apply)
      [32m+[0m[0m secondary_queue_host               = (known after apply)
      [32m+[0m[0m secondary_queue_microsoft_endpoint = (known after apply)
      [32m+[0m[0m secondary_queue_microsoft_host     = (known after apply)
      [32m+[0m[0m secondary_table_endpoint           = (known after apply)
      [32m+[0m[0m secondary_table_host               = (known after apply)
      [32m+[0m[0m secondary_table_microsoft_endpoint = (known after apply)
      [32m+[0m[0m secondary_table_microsoft_host     = (known after apply)
      [32m+[0m[0m secondary_web_endpoint             = (known after apply)
      [32m+[0m[0m secondary_web_host                 = (known after apply)
      [32m+[0m[0m secondary_web_internet_endpoint    = (known after apply)
      [32m+[0m[0m secondary_web_internet_host        = (known after apply)
      [32m+[0m[0m secondary_web_microsoft_endpoint   = (known after apply)
      [32m+[0m[0m secondary_web_microsoft_host       = (known after apply)
      [32m+[0m[0m sftp_enabled                       = false
      [32m+[0m[0m shared_access_key_enabled          = true
      [32m+[0m[0m table_encryption_key_type          = "Service"

      [32m+[0m[0m blob_properties (known after apply)

      [32m+[0m[0m network_rules (known after apply)

      [32m+[0m[0m queue_properties (known after apply)

      [32m+[0m[0m routing (known after apply)

      [32m+[0m[0m share_properties (known after apply)

      [32m+[0m[0m static_website (known after apply)
    }

[1m  # azurerm_storage_container.demo[0m will be created
[0m  [32m+[0m[0m resource "azurerm_storage_container" "demo" {
      [32m+[0m[0m container_access_type             = "private"
      [32m+[0m[0m default_encryption_scope          = (known after apply)
      [32m+[0m[0m encryption_scope_override_enabled = true
      [32m+[0m[0m has_immutability_policy           = (known after apply)
      [32m+[0m[0m has_legal_hold                    = (known after apply)
      [32m+[0m[0m id                                = (known after apply)
      [32m+[0m[0m metadata                          = (known after apply)
      [32m+[0m[0m name                              = "documenti"
      [32m+[0m[0m resource_manager_id               = (known after apply)
      [32m+[0m[0m storage_account_id                = (known after apply)
      [32m+[0m[0m url                               = (known after apply)
    }

[1mPlan:[0m 3 to add, 0 to change, 0 to destroy.
[0m