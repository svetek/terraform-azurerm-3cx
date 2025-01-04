output "pbx_installation_ip" {
  value = "http://${azurerm_public_ip.pbx-public-ip.ip_address}:5015?v=2"
}

output "pbx_public_ip" {
  value = "${azurerm_public_ip.pbx-public-ip.ip_address}"
}

output "ssh_public_key" {
  value = azurerm_key_vault_secret.rsa_vm_ssh_private
}

output "vm_private_key" {
  value = tls_private_key.rsa_vm_ssh.private_key_pem
}

# output "backup3cx-ssh-key" {
#   value = tls_private_key.rsa-4096-ssh-key.private_key_openssh
#   sensitive = true
# }