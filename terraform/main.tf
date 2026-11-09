# ==============================================================================
# ENTERPRISE ZERO-TRUST LANDING ZONE (ROOT ORCHESTRATION)
# Architecture Lead: Abhishek Chauhan
# ==============================================================================

# Primary Region Core Resource Group (East US)
resource "azurerm_resource_group" "primary_rg" {
  name     = "${var.prefix}-${var.environment}-primary-rg"
  location = var.primary_location
  tags     = var.mandatory_tags
}

# Secondary Region Disaster Recovery Resource Group (Central US)
resource "azurerm_resource_group" "secondary_rg" {
  name     = "${var.prefix}-${var.environment}-dr-secondary-rg"
  location = var.secondary_location
  tags     = var.mandatory_tags
}

# 1. Continuous Observability & Log Analytics Module (90d retention)
module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.primary_rg.name
  location            = var.primary_location
  prefix              = var.prefix
  admin_email         = var.admin_email
  tags                = var.mandatory_tags
}

# 2. Hub-and-Spoke Networking Module (Azure Firewall IDPS, Bastion, NSGs, UDR)
module "networking" {
  source                       = "./modules/networking"
  resource_group_name          = azurerm_resource_group.primary_rg.name
  location                     = var.primary_location
  prefix                       = var.prefix
  hub_address_space            = var.hub_address_space
  spoke_workload_address_space = var.spoke_workload_address_space
  spoke_data_address_space     = var.spoke_data_address_space
  tags                         = var.mandatory_tags
}

# 3. Zero-Trust Security Module (Key Vault Purge Protection, CMK 4096-bit, Defender, Sentinel)
module "security" {
  source                     = "./modules/security"
  resource_group_name        = azurerm_resource_group.primary_rg.name
  location                   = var.primary_location
  prefix                     = var.prefix
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = var.mandatory_tags
}

# 4. Enterprise Backup Module (Recovery Services Vault with GFS 5-Year Retention)
module "backup" {
  source              = "./modules/backup"
  resource_group_name = azurerm_resource_group.primary_rg.name
  location            = var.primary_location
  prefix              = var.prefix
  tags                = var.mandatory_tags
}

# 5. Disaster Recovery (BCDR) Module (Multi-Region ASR 15m RPO, RA-GRS, Traffic Manager)
module "bcdr" {
  source                        = "./modules/bcdr"
  primary_resource_group_name   = azurerm_resource_group.primary_rg.name
  secondary_resource_group_name = azurerm_resource_group.secondary_rg.name
  primary_location              = var.primary_location
  secondary_location            = var.secondary_location
  prefix                        = var.prefix
  recovery_vault_id             = module.backup.recovery_vault_id
  recovery_vault_name           = module.backup.recovery_vault_name
  tags                          = var.mandatory_tags
}

# 6. Policy Enforcement, Governance & FinOps Module (CIS v2.0, Locks, Budgets)
module "governance" {
  source                      = "./modules/governance"
  primary_resource_group_id   = azurerm_resource_group.primary_rg.id
  primary_resource_group_name = azurerm_resource_group.primary_rg.name
  monthly_budget_amount       = var.monthly_budget_amount
  contact_emails              = [var.admin_email]
  tags                        = var.mandatory_tags
}
