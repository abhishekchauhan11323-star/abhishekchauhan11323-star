# ==============================================================================
# DISASTER RECOVERY (BCDR) MULTI-REGION ARCHITECTURE (EAST US <-> CENTRAL US)
# ==============================================================================

# RA-GRS Resilient Storage Account
resource "azurerm_storage_account" "bcdr_storage" {
  name                     = "${replace(var.prefix, "-", "")}ragrsstore"
  resource_group_name      = var.primary_resource_group_name
  location                 = var.primary_location
  account_tier             = "Standard"
  account_replication_type = "RAGRS" # Read-Access Geo-Redundant Storage
  min_tls_version          = "TLS1_2"
  enable_https_traffic_only = true

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
  }

  tags = var.tags
}

# Azure Site Recovery (ASR) Fabrics across Paired Regions
resource "azurerm_site_recovery_fabric" "primary" {
  name                = "${var.prefix}-fabric-eastus"
  resource_group_name = var.primary_resource_group_name
  recovery_vault_name = var.recovery_vault_name
  location            = var.primary_location
}

resource "azurerm_site_recovery_fabric" "secondary" {
  name                = "${var.prefix}-fabric-centralus"
  resource_group_name = var.primary_resource_group_name
  recovery_vault_name = var.recovery_vault_name
  location            = var.secondary_location
}

# Protection Containers
resource "azurerm_site_recovery_protection_container" "primary" {
  name                 = "${var.prefix}-container-eastus"
  resource_group_name  = var.primary_resource_group_name
  recovery_vault_name  = var.recovery_vault_name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
}

resource "azurerm_site_recovery_protection_container" "secondary" {
  name                 = "${var.prefix}-container-centralus"
  resource_group_name  = var.primary_resource_group_name
  recovery_vault_name  = var.recovery_vault_name
  recovery_fabric_name = azurerm_site_recovery_fabric.secondary.name
}

# ASR Replication Policy: Strict 15-Minute RPO Threshold
resource "azurerm_site_recovery_replication_policy" "asr_policy_15m" {
  name                                                 = "policy-asr-15m-rpo"
  resource_group_name                                  = var.primary_resource_group_name
  recovery_vault_name                                  = var.recovery_vault_name
  recovery_point_retention_in_minutes                  = 1440 # 24 hours
  application_consistent_snapshot_frequency_in_minutes = 240  # 4 hours
  rpo_threshold_in_seconds                             = 900  # 15 Minutes RPO SLA
}

# Traffic Manager Profile with Priority Auto-Failover
resource "azurerm_traffic_manager_profile" "tm" {
  name                   = "${var.prefix}-tm-global"
  resource_group_name    = var.primary_resource_group_name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "${var.prefix}-tm"
    ttl           = 30
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/healthz"
    interval_in_seconds          = 10
    timeout_in_seconds           = 5
    tolerated_number_of_failures = 2
  }

  tags = var.tags
}
