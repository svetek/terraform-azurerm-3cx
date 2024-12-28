# Create virtual network
resource "azurerm_virtual_network" "pbx-virtual-network" {
  name                = "${var.vm_name}-Vnet"
  address_space       = ["10.0.0.0/29"]
  location            = azurerm_resource_group.RG-3CX-GROUP.location
  resource_group_name = azurerm_resource_group.RG-3CX-GROUP.name

  tags = {
    Company = "SVETEK"
    Name = "3CX VM MODULE"
    environment = "PROD"
  }
}

# Create subnet
resource "azurerm_subnet" "pbx-virtual-subnet" {
  name                 = "${var.vm_name}-Subnet"
  resource_group_name  = azurerm_resource_group.RG-3CX-GROUP.name
  virtual_network_name = azurerm_virtual_network.pbx-virtual-network.name
  address_prefixes       = ["10.0.0.0/29"]
  service_endpoints    = ["Microsoft.Storage"]
  private_endpoint_network_policies="Enabled"
}

resource "azurerm_subnet_network_security_group_association" "pbx-sec-group-association" {
  subnet_id                 = azurerm_subnet.pbx-virtual-subnet.id
  network_security_group_id = azurerm_network_security_group.pbx-nsg.id
}

