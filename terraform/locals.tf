resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  vpc_name    = var.custom_vpc_name == null ? "vpc-${var.project}-${var.env}-${var.region}" : var.custom_vpc_name
  bucket_name = "${var.project}-${var.env}-${var.region}-rootbucket-${random_id.bucket_suffix.hex}"
}