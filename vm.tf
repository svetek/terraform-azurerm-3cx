
resource "tls_private_key" "rsa_vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_password" "pbx-ssh-password" {
  length           = 20
  special          = true
}

resource "azurerm_public_ip" "pbx-public-ip" {
  name                = "${var.vm_name}-public-Ip"
  resource_group_name = azurerm_resource_group.RG-3CX-GROUP.name
  location            = azurerm_resource_group.RG-3CX-GROUP.location
  allocation_method   = "Static"
  #  domain_name_label = "cx1"
}

data "azurerm_public_ip" "pbx-public-ip" {
  name = "${var.vm_name}-public-Ip"
  resource_group_name = azurerm_resource_group.RG-3CX-GROUP.name

  depends_on = [ azurerm_virtual_machine.pbx ]
}


resource "azurerm_network_interface" "pbx-network-interface" {
  name                      = "${var.vm_name}-nic"
  location                  = "${var.region}"
  resource_group_name       = azurerm_resource_group.RG-3CX-GROUP.name
  accelerated_networking_enabled = "${var.enable_accelerated_networking}"
  dns_servers = ["8.8.8.8","1.1.1.1"]

  ip_configuration {
    name                     = "${var.vm_name}-nic-01"
    subnet_id                = azurerm_subnet.pbx-virtual-subnet.id
    public_ip_address_id     = azurerm_public_ip.pbx-public-ip.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    Company = "SVETEK"
    Name = "3CX VM MODULE"
    environment = "PROD"
  }

}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content      = local.cloud_init
  }
}


resource "azurerm_virtual_machine" "pbx" {
  name                  = "${var.vm_name}"
  location              = "${var.region}"
  resource_group_name   = azurerm_resource_group.RG-3CX-GROUP.name
  network_interface_ids = [azurerm_network_interface.pbx-network-interface.id]
  vm_size               = "${var.vm_size}"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id        = "${var.vm_image_id}"
    publisher = "${var.vm_publisher}"
    offer     = "${var.vm_offer}"
    sku       = "${var.vm_sku}"
    version   = "${var.vm_version}"
  }

  storage_os_disk {
    name              = "${lower(var.vm_name)}-OSDISK-1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "${var.vm_storage_os_disk_size}"
  }

  #  storage_data_disk {
  #    name              = "${lower(var.vm_name)}-RECDISK-1"
  #    caching           = "None"
  #    create_option     = "Empty"
  #    managed_disk_type = "Standard_LRS"
  #    disk_size_gb      = "10"
  #    lun               = 1
  #  }

  os_profile {
    computer_name  = "${var.vm_name}-1"
    admin_username = "${var.local_admin_username}"
    admin_password = "${random_password.pbx-ssh-password.result}"
    custom_data = data.template_cloudinit_config.config.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = tls_private_key.rsa_vm_ssh.public_key_openssh
      path     = "/home/${var.local_admin_username}/.ssh/authorized_keys"
    }
  }

  tags = {
    Company = "SVETEK"
    Name = "3CX VM MODULE"
    environment = "PROD"
  }
  //  lifecycle {
  //    prevent_destroy = true
  //  }
}
