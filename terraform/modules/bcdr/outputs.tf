output "bcdr_storage_id" {
  value = azurerm_storage_account.bcdr_storage.id
}

output "traffic_manager_fqdn" {
  value = azurerm_traffic_manager_profile.tm.fqdn
}

output "asr_policy_id" {
  value = azurerm_site_recovery_replication_policy.asr_policy_15m.id
}
