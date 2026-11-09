variable "prefix" {
  type        = string
  description = "Standard resource prefix for naming conventions"
  default     = "ent-lz"
}

variable "environment" {
  type        = string
  description = "Target environment tier (prod, stg, dev)"
  default     = "prod"
}

variable "primary_location" {
  type        = string
  description = "Primary deployment Azure region"
  default     = "eastus"
}

variable "secondary_location" {
  type        = string
  description = "Secondary disaster recovery (BCDR) paired Azure region"
  default     = "centralus"
}

variable "hub_address_space" {
  type        = list(string)
  description = "CIDR block for the centralized Hub VNet"
  default     = ["10.0.0.0/16"]
}

variable "spoke_workload_address_space" {
  type        = list(string)
  description = "CIDR block for the Workload Spoke VNet"
  default     = ["10.1.0.0/16"]
}

variable "spoke_data_address_space" {
  type        = list(string)
  description = "CIDR block for the Data Spoke VNet"
  default     = ["10.2.0.0/16"]
}

variable "monthly_budget_amount" {
  type        = number
  description = "FinOps monthly budget threshold in USD"
  default     = 5000
}

variable "admin_email" {
  type        = string
  description = "CloudOps alert notification email address"
  default     = "abhishekchauhan@example.com"
}

variable "mandatory_tags" {
  type        = map(string)
  description = "Mandatory governance and FinOps tags enforced across all resources"
  default = {
    Environment       = "Production"
    Owner             = "Abhishek Chauhan"
    ArchitectureTier  = "Enterprise-Zero-Trust-Landing-Zone"
    Compliance        = "CIS-Azure-Foundations-v2.0"
    CostCenter        = "Cloud-Engineering-770"
    DisasterRecovery  = "Multi-Region-ASR-15m"
    ManagedBy         = "Terraform"
  }
}
