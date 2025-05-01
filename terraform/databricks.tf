resource "random_id" "iam_suffix" {
  byte_length = 4
}

module "mws_credentials" {
  count  = 1
  source = "./modules/crossaccount_credentials"

  databricks_account_id = data.aws_ssm_parameter.this["databricks_account_id"].value

  resources_names = {
    cross_account_role  = "${var.project}-${var.env}-${var.region}-crossaccount-role-${random_id.iam_suffix.hex}"
    aws_iam_role_policy = "${var.project}-${var.env}-${var.region}-crossaccount-policy-${random_id.iam_suffix.hex}"
    db_mws_credentials  = "${var.project}-${var.env}-${var.region}-credentials-${random_id.iam_suffix.hex}"
  }

  tags                 = var.tags

  providers = {
    databricks = databricks.mws
  }
}

module "databricks_workspace" {
  source = "./modules/databricks"

  region = var.region

  account_id                 = data.aws_ssm_parameter.this["databricks_account_id"].value
  storage_configuration_id   = module.root_bucket[0].storage_configuration_id
  credentials_id             = module.mws_credentials[0].credentials_id
  workspace_name             = "${var.project}-${var.env}-${var.region}-workspace"

  network_name       = module.vpc[0].name
  vpc_id             = module.vpc[0].vpc_id
  subnet_ids         = module.vpc[0].private_subnets
  security_group_ids = [coalesce(module.vpc[0].default_security_group_id)]

  vpc_endpoints = [{
    type = "rest"
    name = "${var.project}-${var.env}-${var.region}-rest-${module.vpc[0].vpc_id}"
    id   = aws_vpc_endpoint.backend_rest[0].id
    }, {
    type = "relay"
    name = "${var.project}-${var.env}-${var.region}-relay-${module.vpc[0].vpc_id}"
    id   = aws_vpc_endpoint.backend_relay[0].id
  }]

  providers = {
    databricks = databricks.mws
  }
}

module "databricks_runtime" {
  count = var.databricks_runtime_enabled ? 1 : 0
  source = "./modules/databricks_runtime"

  workspace_groups             = var.databricks_workspace_groups
  region                       = var.region
  clusters                     = var.databricks_cluster_configs
  sql_endpoint                 = var.databricks_sql_endpoint
  custom_config                = var.databricks_workspace_custom_config
  ip_addresses                 = var.allowed_ip_address
  databricks_secret_scope_name = var.databricks_secret_scope_name

  providers = {
    databricks.workspace = databricks.workspace
  }
}
