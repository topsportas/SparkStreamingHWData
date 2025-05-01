variable "databricks_account_id" {
  description = "Account Id that could be found in the top right corner of https://accounts.cloud.databricks.com/"
  type        = string
}

variable "resources_names" {
  type = object({
    root_bucket                  = string,
    db_mws_storage_configuration = string
  })
  description = "Names of created resources"
}

variable "tags" {
  type        = map(any)
  description = "Resource tags"
  default     = {}
}
