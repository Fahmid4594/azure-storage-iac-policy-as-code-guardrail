resource "azurerm_resource_group" "main"{

name = "azure-resources"

location = "eastus"

}

resource "azurerm_storage_account" "main" {

name                 =  "insecurestorage459"
resource_group_name  = azurerm_resource_group.main.name
location             = azurerm_resource_group.main.location
account_tier         = "Standard"
account_replication_type = "LRS"

https_traffic_only_enabled = false

allow_nested_items_to_be_public = true

min_tls_version = "TLS1_0"






}





