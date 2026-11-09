# ==============================================================================
# RECOVERY SERVICES VAULT & ENTERPRISE GFS RETENTION POLICY
# ==============================================================================

resource "azurerm_recovery_services_vault" "rsv" {
  name                = "${var.prefix}-rsv-backup"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  storage_mode_type   = "GeoRedundant"
  cross_region_restore_enabled = true
  soft_delete_enabled = true

  tags = var.tags
}

# Grandfather-Father-Son (GFS) Backup Policy
resource "azurerm_backup_policy_vm" "gfs_policy" {
  name                = "policy-gfs-enterprise-retention"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  timezone            = "UTC"

  # Daily (Son) - 30 Days Retention
  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }

  # Weekly (Father) - 12 Weeks Retention
  retention_weekly {
    count    = 12
    weekdays = ["Sunday"]
  }

  # Monthly (Grandfather) - 60 Months (5 Years Archive) Retention
  retention_monthly {
    count    = 60
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }

  # Yearly Archive - 5 Years
  retention_yearly {
    count    = 5
    weekdays = ["Sunday"]
    weeks    = ["First"]
    months   = ["January"]
  }
}
