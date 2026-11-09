output "recovery_vault_id" {
  value = azurerm_recovery_services_vault.rsv.id
}

output "recovery_vault_name" {
  value = azurerm_recovery_services_vault.rsv.name
}

output "backup_policy_id" {
  value = azurerm_backup_policy_vm.gfs_policy.id
}
