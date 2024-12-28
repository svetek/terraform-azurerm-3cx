
# Create a resource group
resource "azurerm_resource_group" "RG-3CX-GROUP" {
  name     = "${var.vm_resource_group_name}"
  location = "${var.region}"

  tags = {
    Company = "SVETEK"
    Name = "3CX VM MODULE"
    environment = "PROD"
  }
}
