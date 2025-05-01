variable "databricks_account_id" {
  description = "Account Id that could be found in the top right corner of https://accounts.cloud.databricks.com/"
  type        = string
}

variable "resources_names" {
  type = object({
    cross_account_role  = string,
    aws_iam_role_policy = string,
    db_mws_credentials  = string
  })
  description = "Names of created resources"
}

variable "tags" {
  type        = map(any)
  description = "Resource tags"
  default     = {}
}

variable "permissions_boundary" {
  type        = string
  description = "Optional permission boundary ARN to be attached to assumable role"
  default     = ""
}

variable "preexisting_role_arn" {
  type        = string
  description = "Preexisting role ARN. New role and policy will not be created, if provided"
  default     = ""
}
