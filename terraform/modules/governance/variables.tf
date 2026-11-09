variable "primary_resource_group_id" {
  type = string
}

variable "primary_resource_group_name" {
  type = string
}

variable "monthly_budget_amount" {
  type = number
}

variable "contact_emails" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}
