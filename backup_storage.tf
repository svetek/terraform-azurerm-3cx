resource "random_string" "backup_random" {
  length  = 10
  upper   = false
  special = false
}

resource "tls_private_key" "rsa-4096-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_storage_account" "backup_storage" {
  name                     = "backup-${random_string.backup_random.id}"
  resource_group_name      = azurerm_resource_group.RG-3CX-GROUP.name
  location                 = azurerm_resource_group.RG-3CX-GROUP.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  nfsv3_enabled            = "false"
  is_hns_enabled           = "true"
  sftp_enabled             = "true"
#   https_traffic_only_enabled = "false"


  tags = {
    Company = "SVETEK"
    Name = "3CX VM MODULE"
    environment = "PROD"
  }

  #  lifecycle {
  #    prevent_destroy = true
  #  }

}

resource "azurerm_storage_container" "backup_container" {
  name                  = "backup-3cx"
  storage_account_name  = azurerm_storage_account.backup_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_account_local_user" "sftp_user" {
  name                 = "3cxbackup"
#   storage_account_name = azurerm_storage_account.backup_storage.name
#   home_directory       = azurerm_storage_container.backup_container.name

  has_ssh_key = true

  ssh_authorized_key {
    key = tls_private_key.rsa-4096-ssh-key.public_key_openssh
  }

  permissions {
    create = true
    read   = true
    write  = true
    delete = false # Adjust as needed
    list   = true
  }
  storage_account_id = azurerm_storage_account.backup_storage.id

}
