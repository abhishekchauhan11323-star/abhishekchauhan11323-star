data "azurerm_client_config" "current" {}

# ==============================================================================
# AZURE KEY VAULT WITH RBAC & PURGE PROTECTION (ZERO-TRUST VAULT)
# ==============================================================================
resource "azurerm_key_vault" "kv" {
  name                        = "${var.prefix}-kv-sec"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium" # Hardware HSM support
  enable_rbac_authorization   = true      # Strict Azure RBAC mode
  purge_protection_enabled    = true      # Tamper & Ransomware Protection
  soft_delete_retention_days  = 90
  public_network_access_enabled = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  tags = var.tags
}

# ==============================================================================
# CMK 4096-BIT DISK ENCRYPTION SET
# ==============================================================================
resource "azurerm_key_vault_key" "cmk_disk_key" {
  name         = "cmk-disk-4096-rsa"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA-HSM"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_key_vault.kv]
}

resource "azurerm_disk_encryption_set" "des" {
  name                = "${var.prefix}-des-cmk"
  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_key_id    = azurerm_key_vault_key.cmk_disk_key.id

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Grant Key Vault Crypto Service Encryption User role to Disk Encryption Set
resource "azurerm_role_assignment" "des_kv_crypto" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.des.identity[0].principal_id
}

# ==============================================================================
# DEFENDER FOR CLOUD (CONTINUOUS THREAT & VULNERABILITY ASSESSMENT)
# ==============================================================================
resource "azurerm_security_center_subscription_pricing" "defender_vms" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "defender_storage" {
  tier          = "Standard"
  resource_type = "StorageAccounts"
}

resource "azurerm_security_center_subscription_pricing" "defender_containers" {
  tier          = "Standard"
  resource_type = "Containers"
}

# ==============================================================================
# MICROSOFT SENTINEL SIEM / SOAR LOG ANALYTICS ONBOARDING
# ==============================================================================
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id = var.log_analytics_workspace_id
}
