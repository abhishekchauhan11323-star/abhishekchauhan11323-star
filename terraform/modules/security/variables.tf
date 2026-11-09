variable "resource_group_name" {
  type        = string
  description = "Target Resource Group name for Security resources"
}

variable "location" {
  type        = string
  description = "Azure region for security resources"
}

variable "prefix" {
  type        = string
}

variable "tags" {
  type        = map(string)
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for Sentinel onboarding"
}
