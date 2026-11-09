output "hub_vnet_id" {
  description = "Centralized Hub Virtual Network Resource ID"
  value       = module.networking.hub_vnet_id
}

output "azure_firewall_private_ip" {
  description = "Azure Firewall Premium Private IP for UDR 0.0.0.0/0 route tunneling"
  value       = module.networking.firewall_private_ip
}

output "azure_firewall_public_ip" {
  description = "Azure Firewall Premium Public Ingress/Egress IP"
  value       = module.networking.firewall_public_ip
}

output "key_vault_uri" {
  description = "Azure Key Vault URI with RBAC & Purge Protection"
  value       = module.security.key_vault_uri
}

output "cmk_disk_encryption_set_id" {
  description = "CMK 4096-bit Disk Encryption Set ID"
  value       = module.security.disk_encryption_set_id
}

output "log_analytics_workspace_id" {
  description = "Central Log Analytics Workspace ID (90-day retention)"
  value       = module.monitoring.log_analytics_workspace_id
}

output "recovery_services_vault_name" {
  description = "Recovery Services Vault Name for GFS Backups & ASR"
  value       = module.backup.recovery_vault_name
}

output "traffic_manager_fqdn" {
  description = "Traffic Manager Multi-Region Priority Failover FQDN"
  value       = module.bcdr.traffic_manager_fqdn
}
