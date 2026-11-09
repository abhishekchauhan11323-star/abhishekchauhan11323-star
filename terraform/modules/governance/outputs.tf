output "enterprise_root_mg_id" {
  value = azurerm_management_group.mg_enterprise_root.id
}

output "platform_core_mg_id" {
  value = azurerm_management_group.mg_core_platform.id
}

output "budget_id" {
  value = azurerm_consumption_budget_resource_group.budget.id
}
