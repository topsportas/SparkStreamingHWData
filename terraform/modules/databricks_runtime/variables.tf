variable "workspace_groups" {
  type = list(object({
    group_name    = string
    group_members = list(string)
  }))
  default = []
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "sql_endpoint" {
  type = set(object({
    name                 = string
    cluster_size         = optional(string, "2X-Small")
    max_num_clusters     = optional(number, 1)
    enable_photon        = optional(bool, false)
    spot_instance_policy = optional(string, "COST_OPTIMIZED")
    warehouse_type       = optional(string, "PRO")
    key                  = optional(string, "Key1")
    value                = optional(string, "Value1")
  }))
  description = "Set of objects with parameters to configure SQL Endpoint and assign permissions to it for certain custom groups"
  default     = []
}

variable "clusters" {
  type = set(object({
    cluster_name            = string
    spark_version           = optional(string, "13.3.x-scala2.12")
    node_type_id            = optional(string, "m6i.large")
    autotermination_minutes = optional(number, 20)
    min_workers             = optional(number, 1)
    max_workers             = optional(number, 2)
    availability            = optional(string, "ON_DEMAND")
    zone_id                 = optional(string, "auto")
    first_on_demand         = optional(number, 1)
    spot_bid_price_percent  = optional(number, 100)
  }))
  description = "Set of objects with parameters to configure Databricks clusters and assign permissions to it for certain custom groups"
  default     = []
}

variable "custom_config" {
  type        = map(string)
  description = "Map of AD databricks workspace custom config"
}

variable "ip_addresses" {
  type = map(string)
  default = {
    "all" = "0.0.0.0/0"
  }
}

variable "databricks_secret_scope_name" {
  type        = string
  description = "Databricks Secret Scope name"
}
