# terraform-azurerm-3cx

3CX v20 deployment module for Azure cloud

## How to use

### Terraforms files

Prerequisites: Install terraform and azure-cli.  
https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
https://www.terraform.io/downloads

Create a directory with the name of your organization or better yet, a resource group name and inside the newly created directory create 3 files.

terraform.tfvars

```yaml
#az logout
#az login --use-device-code
#az account list --output table
#az account set --subscription  XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
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
            version = "4.14.0"
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
  version = "0.1.15"
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

  firewall_allow_voipproviders = ["XXX.XX.238.134/32", "XXX.XX.2.12/32"]
  firewall_allow_clientip = ["192.168.1.1/32"]
  vault_ad_sec_group = "L2 Support"
  email_notification = "<helpdesk_address>@svetek.com"
  storage_for_records          = false
}

output "pbx_installation_ip" {
  value = "${module.CX.pbx_installation_ip}"
}

#output "pbx_installation_url" {
#  value = "${module.CX.pbx_installation_url}"
#}
```

### Deployment

Frequently adjusted parameters based on your environment. 

| Parameter Name  | Description   | File Name   |
|------------|------------|------------|
| tenant_id | Target Azure Tenant ID | terraform.tf|
| subscription_id | Target Azure Subscription ID | terraform.tf |
| version | Version of the 3CX module | pbx-3cx.tf |
| vm_resource_group_name | RG name with 3CX resources| pbx-3cx.tf |
| region | Deployment region | pbx-3cx.tf |
| vm_name | 3CX VM name | pbx-3cx.tf |
| vm_size | Desired SKU | pbx-3cx.tf |
| vm_storage_os_disk_size | 3CX OS disk size | pbx-3cx.tf |
| firewall_allow_voipproviders | SIP trunk provider IPs (if required by provider) | pbx-3cx.tf |

You need auth in your original tenant on Azure after that make switch to subscribtion

```bash
    az login --use-device-code
    az account list --output table
    az account set --subscription  <Azure subscribtion where you want to deploy>
    az account show
    az account list-locations -o table
    az vm list-skus --size Standard_B --all --output table
```

Inside directory with terraform files run next command:

```bash
    # Download modules and packages for deploy 
    terraform get 
    terraform init 
    # Plan deploy (see what changes planed by deploy scripts)
    terraform plan 
    # Run deploy process 
    terraform apply 
```

All passwords and ssh keys can be found in Azure key vault in the corresponding resource group.
3CX now asks you to set the initial password upon successful deployment.
Successful deployment generates an output with the URL to be used to load the 3CX configuration and initialize the installation. This URL needs to be used quickly and before restarting your VM (restarting VM invalidates the URL prompting redeployment).

### Troubleshooting

#### Deleting Keyvault

Occasionally, the apply command might fail and you need to clean up the resource group. If cleanup involves deleting the keyvault, by default Azure performs soft delete, therefore, to reapply configuration with previously generated values, perform the keyvault cleanup using the following commands:

```bash
az keyvault list-deleted
az keyvault purge --name v-test-3cx-XXXXX --location westus3
```

#### Resource Availability

Not all Azure regions might have VMs of the selected size (our default is size Standard_B) due to data center limitations or popularity of the SKU. For this try looking up the next available VM or change to a locaiton that has the needed SKU. This applies to other resources. 

#### Maintaining Resource State Example

terraform.tf

```yaml
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.14.0"
    }
  }
  backend "azurerm" {
    resource_group_name = "RG-US-Terraform-State"
    storage_account_name = "<storage_name>"
    container_name       = "tfstate-prod"
    key                  = "<subscription_name>/<3CX_CLIENT_AND_VM_NAME>.tfstate"
    use_msi              = false
    subscription_id      = "<state_subscription_ID>"
    tenant_id            = "<tenant_ID>"
  }
}


variable "tenant_id" {}
variable "subscription_id" {}

provider "azurerm" {
  features {
  }
  tenant_id = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
}

```

Additional Parameter to consider when mainintng multiple 3CX vm states

| Parameter Name  | Description   | File Name   |
|------------|------------|------------|
| resource_group_name | TFState RG Name | terraform.tf |
| storage_account_name | TFState Storage Account Name | terraform.tf |
| key | Unique and Descriptive Name of the Resource vironment to maintain | terraform.tf |
| subscription_id | TFState Azure Subscription ID | terraform.tf |
| tenant_id | TFState Azure Tenant ID | terraform.tf |
