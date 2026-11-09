# ==============================================================================
# FINOPS & GOVERNANCE: MANAGEMENT GROUPS, LOCKS, AND TIERED BUDGETS
# ==============================================================================

# Management Groups Hierarchy
resource "azurerm_management_group" "mg_enterprise_root" {
  display_name = "Enterprise-Root-LandingZone"
  name         = "mg-enterprise-root-lz"
}

resource "azurerm_management_group" "mg_core_platform" {
  display_name               = "Platform-Core-Services"
  name                       = "mg-platform-core"
  parent_management_group_id = azurerm_management_group.mg_enterprise_root.id
}

resource "azurerm_management_group" "mg_workloads" {
  display_name               = "Workloads-Production"
  name                       = "mg-workloads-prod"
  parent_management_group_id = azurerm_management_group.mg_enterprise_root.id
}

# Resource Lock (CanNotDelete on Production Core)
resource "azurerm_management_lock" "resource_group_lock" {
  name       = "lock-cannotdelete-prod"
  scope      = var.primary_resource_group_id
  lock_level = "CanNotDelete"
  notes      = "Production-grade lock preventing accidental termination of Zero-Trust landing zone"
}

# Tiered FinOps Budget Alerts (50%, 75%, 90%, 100%)
resource "azurerm_consumption_budget_resource_group" "budget" {
  name              = "budget-finops-tier-alerts"
  resource_group_id = var.primary_resource_group_id
  amount            = var.monthly_budget_amount
  time_grain        = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00'Z'", timestamp())
  }

  notification {
    enabled   = true
    threshold = 50.0
    operator  = "GreaterThan"
    contact_emails = var.contact_emails
  }

  notification {
    enabled   = true
    threshold = 75.0
    operator  = "GreaterThan"
    contact_emails = var.contact_emails
  }

  notification {
    enabled   = true
    threshold = 90.0
    operator  = "GreaterThan"
    contact_emails = var.contact_emails
  }

  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    contact_emails = var.contact_emails
  }
}
