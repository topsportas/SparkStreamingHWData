output "s3_bucket_id" {
  value = module.db_root_bucket.s3_bucket_id
}

output "storage_configuration_id" {
  value = databricks_mws_storage_configurations.this.storage_configuration_id
}
