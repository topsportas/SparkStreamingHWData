terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "ssm"
  region = coalesce(var.ssm_region, var.region)
}

provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com"
  account_id    = data.aws_ssm_parameter.this["databricks_account_id"].value
  client_id     = data.aws_ssm_parameter.this["databricks_admin_sp_id"].value
  client_secret = data.aws_ssm_parameter.this["databricks_admin_sp_secret"].value
}

provider "databricks" {
  alias         = "workspace"
  host          = module.databricks_workspace.databricks_host
  client_id     = data.aws_ssm_parameter.this["databricks_admin_sp_id"].value
  client_secret = data.aws_ssm_parameter.this["databricks_admin_sp_secret"].value
}

#provider "databricks" {
#  alias      = "account"
#  host       = "https://accounts.azuredatabricks.net"
#  account_id = data.aws_ssm_parameter.this["databricks_account_id"].value
#}
