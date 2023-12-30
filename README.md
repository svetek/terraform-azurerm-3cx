# terraform-azurerm-3cx
Deploy 3CX v20 to Azure cloud 

## How to use
### Terraforms files

Before start on your system will be installed terraform and azure-cli.  
Create directory with name organization and inside new directory create 3 files.

https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
https://www.terraform.io/downloads

terraform.tfvars
```yaml
#az logout
#az login --use-device-code
#az account list --output table
#az account set --subscription  b826e133-2fb1-4d32-90b3-8396852a9d43
#az account show
#az account list-locations
# az account list-locations -o table
#az vm list-skus --size Standard_B --all --output table

tenant_id = "<Azure tenant ID>"
subscription_id = "<Azure subscription ID>"
```

terraform.tf
```yaml
terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "3.85.0"
        }
    }
}

variable "tenant_id" {}
variable "subscription_id" {}
```


pbx-3cx.tf
```yaml
module "CX" {
  #  count           = 1
  source  = "svetek/3cx/azurerm"
  version = "0.1.0"
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"

  # VMS
  vm_resource_group_name = "RG-DEMO-3CX-US-V20"
  region                 = "westus3"
  vm_name                = "DEMO-3CX"

  vm_size                 = "Standard_B1s"
  enable_accelerated_networking = false
  vm_storage_os_disk_size = 30
  local_admin_username    = "admin3cx"
  vm_timezone             = ""

  # az vm image list -l westus -p 3cx --all
  vm_image_id  = ""
  vm_publisher = "Debian"
  vm_offer     = "debian-12"
  vm_sku       = "12"
  vm_version   = "latest"

  managed_disk_sizes = [""]
  managed_disk_type  = "Standard_LRS"

  firewall_allow_voipproviders = ["216.82.238.134/32", "67.231.2.12/32"]
  firewall_allow_clientip = ["192.168.1.1/32"]
  vault_ad_sec_group = "L2 Support"
  email_notification = "help@svetek.com"
  storage_for_records          = false
}

output "pbx_installation_ip" {
  value = "${module.CX.pbx_installation_ip}"
}

#output "pbx_installation_url" {
#  value = "${module.CX.pbx_installation_url}"
#}
```

### Run deploy
You need auth in your original tenant on Azure after that make switch to subscribtion

    az login --use-device-code
    az account list --output table
    az account set --subscription  <Azure subscribtion where you want to deploy>
    az account show
    az account list-locations -o table
    az vm list-skus --size Standard_B --all --output table

Inside directory with terraform files run next command:

    # Download modules and packages for deploy 
    terraform get 
    terraform init 
    # Plan deploy (see what changes planed by deploy scripts)
    terraform plan 
    # Run deploy process 
    terraform apply 

All passwords and ssh keys you can see on Azure vault on resource group 
