variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "prefix" {
  type = string
}

variable "admin_email" {
  type = string
}

variable "tags" {
  type = map(string)
}
