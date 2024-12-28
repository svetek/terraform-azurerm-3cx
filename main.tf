# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
  }
  tenant_id = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
}

# Create Vault
data "azurerm_client_config" "current" {}













