output "key_vault_id" {
  value = azurerm_key_vault.kv.id
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}

output "disk_encryption_set_id" {
  value = azurerm_disk_encryption_set.des.id
}

output "cmk_key_id" {
  value = azurerm_key_vault_key.cmk_disk_key.id
}
