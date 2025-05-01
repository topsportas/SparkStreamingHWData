data "databricks_aws_bucket_policy" "this" {
  bucket = var.resources_names.root_bucket
}

