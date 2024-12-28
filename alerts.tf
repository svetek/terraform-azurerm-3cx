#data "azurerm_subscription" "primary" {
#}
#
#data "azurerm_role_definition" "owner" {
#  name  = "owner"
#  scope = data.azurerm_subscription.primary.id
#}

resource "azurerm_monitor_action_group" "ag" {
  name                = "${var.vm_name}_support_group"
  resource_group_name = azurerm_resource_group.RG-3CX-GROUP.name
  short_name          = "${var.vm_name}"


  #   arm_role_receiver {
  #     name                    = "owner"
  #     role_id                 = "de139f84-1756-47ae-9be6-808fbbe84772"
  #     use_common_alert_schema = true
  #   }

  email_receiver {
    name                    = "support"
    email_address           = "${var.email_notification}"
    use_common_alert_schema = true
  }

}

resource "azurerm_monitor_metric_alert" "alert" {
  name                = "3cx_cpu_high"
  resource_group_name = azurerm_resource_group.RG-3CX-GROUP.name
  scopes              = [azurerm_virtual_machine.pbx.id]
  description         = "description"
  target_resource_type = "Microsoft.Compute/virtualMachines"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }
}