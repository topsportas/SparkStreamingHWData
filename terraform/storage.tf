resource "random_id" "root_bucket_suffix" {
  byte_length = 4
}

module "root_bucket" {
  count  = 1
  source = "./modules/root_s3_bucket"

  databricks_account_id = data.aws_ssm_parameter.this["databricks_account_id"].value
  resources_names = {
    root_bucket                  = "${var.project}-${var.env}-${var.region}-rootbucket-${random_id.root_bucket_suffix.hex}",
    db_mws_storage_configuration = "${var.project}-${var.env}-${var.region}-rootbucket-${random_id.root_bucket_suffix.hex}"
  }

  tags = var.tags

  providers = {
    databricks = databricks.mws
  }
}