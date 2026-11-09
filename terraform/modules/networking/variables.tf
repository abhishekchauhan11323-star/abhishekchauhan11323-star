variable "resource_group_name" {
  type        = string
  description = "Target Resource Group name for Hub networking"
}

variable "location" {
  type        = string
  description = "Azure region for Hub networking"
}

variable "prefix" {
  type        = string
  description = "Resource prefix"
}

variable "hub_address_space" {
  type        = list(string)
}

variable "spoke_workload_address_space" {
  type        = list(string)
}

variable "spoke_data_address_space" {
  type        = list(string)
}

variable "tags" {
  type        = map(string)
}
