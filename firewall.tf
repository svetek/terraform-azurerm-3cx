resource "azurerm_network_security_group" "pbx-nsg" {
  name                = "${var.vm_name}-NetworkSecurityGroup"
  location            = azurerm_resource_group.RG-3CX-GROUP.location
  resource_group_name = azurerm_resource_group.RG-3CX-GROUP.name

  tags = {
    Company = "SVETEK"
    Name = "3CX VM MODULE"
    environment = "PROD"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  dynamic "security_rule" {
    for_each = var.firewall_allow_voipproviders
    content {
      name                       = "IPs_VOIPPROVIDERS-${security_rule.key}"
      priority                   = (1010 + (security_rule.key * 10))
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "${security_rule.value}"
      destination_address_prefix = "*"
    }
  }

  dynamic "security_rule" {
    for_each = var.firewall_allow_clientip
    content {
      name                       = "IPs_CLIENT-${security_rule.key}"
      priority                   = (1510 + (security_rule.key * 10))
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "${security_rule.value}"
      destination_address_prefix = "*"
    }
  }

  //  security_rule {
  //    name                       = "IPs_BANDWIDTH-${var.firewall_allow_bandwidth_ip_2}"
  //    priority                   = 1007
  //    direction                  = "Inbound"
  //    access                     = "Allow"
  //    protocol                   = "*"
  //    source_port_range          = "*"
  //    destination_port_range     = "*"
  //    source_address_prefix      = "${var.firewall_allow_bandwidth_ip_2}"
  //    destination_address_prefix = "*"
  //  }

  security_rule {
    name                       = "5001_TCP"
    priority                   = 2010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5001"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "5090_TCP"
    priority                   = 2020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5090"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "5090_UDP"
    priority                   = 2030
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "5090"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "5060_TCP"
    priority                   = 2040
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5060"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "5060_UDP"
    priority                   = 2050
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "5060"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "5061_TCP"
    priority                   = 2060
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5061"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "5015_TCP"
    priority                   = 2070
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5015"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "443_TCP"
    priority                   = 2080
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "5062_TCP"
    priority                   = 2090
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5062"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "10600_10998_UDP"
    priority                   = 2100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "10600-10998"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "9000_9398_UDP"
    priority                   = 2110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "9000-9398"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "8088_TCP"
    priority                   = 2120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8088"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
