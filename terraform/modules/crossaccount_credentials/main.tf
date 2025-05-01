resource "aws_iam_role" "cross_account_role" {
  count = var.preexisting_role_arn == "" ? 1 : 0

  name                 = var.resources_names.cross_account_role
  assume_role_policy   = data.databricks_aws_assume_role_policy.this.json
  permissions_boundary = var.permissions_boundary
  description          = "Managed by terraform"
  tags                 = merge(var.tags, { Name = var.resources_names.cross_account_role })
}

resource "aws_iam_role_policy" "this" {
  count = var.preexisting_role_arn == "" ? 1 : 0

  name   = var.resources_names.aws_iam_role_policy
  role   = aws_iam_role.cross_account_role[0].id
  policy = data.databricks_aws_crossaccount_policy.this.json
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_iam_role_policy.this]

  create_duration = "30s"
}

resource "databricks_mws_credentials" "this" {
  account_id       = var.databricks_account_id
  credentials_name = var.resources_names.db_mws_credentials
  role_arn         = coalesce(var.preexisting_role_arn, try(aws_iam_role.cross_account_role[0].arn, ""))

  depends_on = [time_sleep.wait_30_seconds]
}
