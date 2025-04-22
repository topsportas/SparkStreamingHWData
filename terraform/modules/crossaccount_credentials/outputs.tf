output "role_arn" {
  value = coalesce(var.preexisting_role_arn, try(aws_iam_role.cross_account_role[0].arn, ""))
}

output "id" {
  value = databricks_mws_credentials.this.id
}

output "credentials_id" {
  value = databricks_mws_credentials.this.credentials_id
}
