variable "region" {
  type        = string
  description = "AWS region"
}

variable "account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "network_name" {
  type        = string
  description = "Databricks Account network configuration name"
}

variable "workspace_name" {
  type        = string
  description = "Databricks workspace name"
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID"
}

variable "security_group_ids" {
  type        = set(string)
  description = "Set of AWS security group IDs for Databricks Account network configuration"
}

variable "subnet_ids" {
  type        = set(string)
  description = "Set of AWS subnet IDs for Databricks Account network configuration"
}

variable "vpc_endpoints" {
  type = set(object({
    name = string
    type = string
    id   = string
  }))
  description = "Endpoints to register in Databricks account"
}

variable "credentials_id" {
  type        = string
  description = ""
}

variable "storage_configuration_id" {
  type        = string
  description = ""
}

variable "private_access_settings_id" {
  type        = string
  description = ""
  default = ""
}
