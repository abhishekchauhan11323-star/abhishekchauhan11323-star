variable "primary_resource_group_name" {
  type = string
}

variable "secondary_resource_group_name" {
  type = string
}

variable "primary_location" {
  type = string
}

variable "secondary_location" {
  type = string
}

variable "prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "recovery_vault_id" {
  type        = string
  description = "Target Recovery Services Vault ID for ASR"
}

variable "recovery_vault_name" {
  type = string
}
