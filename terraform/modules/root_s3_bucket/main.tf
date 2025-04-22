module "db_root_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.resources_names.root_bucket
  acl    = "private"

  attach_policy = true
  policy        = data.databricks_aws_bucket_policy.this.json
  # Allow deletion of non-empty bucket
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning = {
    status = "Disabled"
  }

  tags = merge(var.tags, { Name = var.resources_names.root_bucket })
}


resource "databricks_mws_storage_configurations" "this" {
  account_id                 = var.databricks_account_id
  storage_configuration_name = var.resources_names.db_mws_storage_configuration
  bucket_name                = var.resources_names.root_bucket
}