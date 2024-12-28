data "azuread_group" "vaultgroup" {
  display_name     = var.vault_ad_sec_group
  security_enabled = true
}

#output "object_id" {
#  value = data.azuread_group.vaultgroup.object_id
#}


resource "random_string" "random_prefix_vault_name" {
  length           = 5
  special          = false
  override_special = "/@£$"
}

resource "azurerm_key_vault" "pbx_vault" {
  name                       = "v-${lower(var.vm_name)}-${random_string.random_prefix_vault_name.result}"
  location                   = azurerm_resource_group.RG-3CX-GROUP.location
  resource_group_name        = azurerm_resource_group.RG-3CX-GROUP.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  enabled_for_disk_encryption = true
  enable_rbac_authorization   = true
  enabled_for_deployment      = true
  purge_protection_enabled    = false

  tags = {
    Company = "SVETEK"
    Name = "3CX VM MODULE"
    environment = "PROD"
  }

}

resource "azurerm_key_vault_access_policy" "pbx_vault_sp_access" {
  key_vault_id = azurerm_key_vault.pbx_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_group.vaultgroup.object_id

  key_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
  ]

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]

  certificate_permissions = [
    "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
  ]
  depends_on = [azurerm_key_vault.pbx_vault]
}

resource "azurerm_role_assignment" "role-secret-officer" {
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azuread_group.vaultgroup.object_id
  scope                = azurerm_key_vault.pbx_vault.id

  depends_on = [azurerm_key_vault_access_policy.pbx_vault_sp_access]

}

resource "azurerm_role_assignment" "role-crypto-officer" {
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = data.azuread_group.vaultgroup.object_id
  scope                = azurerm_key_vault.pbx_vault.id

  depends_on = [azurerm_key_vault_access_policy.pbx_vault_sp_access]

}

resource "azurerm_key_vault_secret" "save_password_vault" {
  name         = "${var.vm_name}-${var.local_admin_username}"
  value        = "${random_password.pbx-ssh-password.result}"
  key_vault_id = azurerm_key_vault.pbx_vault.id

  depends_on = [azurerm_role_assignment.role-secret-officer]

  lifecycle {
    prevent_destroy = true
    ignore_changes = [ value ]
  }
}


# No metods for export private keys
#resource "azurerm_key_vault_key" "rsa_vm_ssh" {
#  name         = "${var.vm_name}-rsa-key"
#  key_vault_id = azurerm_key_vault.pbx_vault.id
#  key_type     = "RSA"
#  key_size     = 2048
#
#  key_opts = [
#    "decrypt",
#    "encrypt",
#    "sign",
#    "unwrapKey",
#    "verify",
#    "wrapKey",
#  ]
#
#  depends_on = [ azurerm_role_assignment.role-crypto-officer ]
#}


# Save 3cx VM ssh key pub / private
resource "azurerm_key_vault_secret" "rsa_vm_ssh_private" {
  name         = "${var.vm_name}-ssh-private"
  value        = base64encode(tls_private_key.rsa_vm_ssh.private_key_pem)
  key_vault_id = azurerm_key_vault.pbx_vault.id
  content_type = "Need Base64 Decoded"
  depends_on = [azurerm_role_assignment.role-secret-officer]

  lifecycle {
    prevent_destroy = true
    ignore_changes = [ value ]
  }

}

resource "azurerm_key_vault_secret" "rsa_vm_ssh_public" {
  name         = "${var.vm_name}-ssh-public"
  value        = base64encode(tls_private_key.rsa_vm_ssh.public_key_openssh)
  key_vault_id = azurerm_key_vault.pbx_vault.id
  content_type = "Need Base64 Decoded"

  depends_on = [azurerm_role_assignment.role-secret-officer]

  lifecycle {
    prevent_destroy = true
    ignore_changes = [ value ]
  }

}

# Save 3cx storage sftp account ssh key pub / private
resource "azurerm_key_vault_secret" "backup_rsa_vm_ssh_private" {
  name         = "backup-ssh-private"
  value        = base64encode(tls_private_key.rsa-4096-ssh-key.private_key_pem)
  key_vault_id = azurerm_key_vault.pbx_vault.id
  content_type = "Need Base64 Decoded"
  depends_on = [azurerm_role_assignment.role-secret-officer]

  lifecycle {
    prevent_destroy = true
    ignore_changes = [ value ]
  }

}

resource "azurerm_key_vault_secret" "backup_rsa_vm_ssh_public" {
  name         = "backup-ssh-public"
  value        = base64encode(tls_private_key.rsa-4096-ssh-key.public_key_openssh)
  key_vault_id = azurerm_key_vault.pbx_vault.id
  content_type = "Need Base64 Decoded"

  depends_on = [azurerm_role_assignment.role-secret-officer]

  lifecycle {
    prevent_destroy = true
    ignore_changes = [ value ]
  }

}