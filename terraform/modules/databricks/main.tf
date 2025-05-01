resource "databricks_mws_networks" "this" {
  account_id         = var.account_id
  network_name       = var.network_name
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids
  vpc_id             = var.vpc_id
}

resource "databricks_mws_workspaces" "this" {
  account_id     = var.account_id
  aws_region     = var.region
  workspace_name = var.workspace_name

  credentials_id             = var.credentials_id
  storage_configuration_id   = var.storage_configuration_id
  network_id                 = databricks_mws_networks.this.network_id
  private_access_settings_id = coalesce(var.private_access_settings_id, try(databricks_mws_private_access_settings.this[0].private_access_settings_id, null))

  token {
    comment = "Terraform"
  }
}

resource "databricks_mws_vpc_endpoint" "this" {
  for_each = { for endpoint in var.vpc_endpoints : endpoint.type => endpoint }

  account_id          = var.account_id
  aws_vpc_endpoint_id = each.value.id
  vpc_endpoint_name   = each.value.name
  region              = var.region
}

resource "databricks_mws_private_access_settings" "this" {
  count = var.private_access_settings_id != "" ? 0 : 1

  account_id                   = var.account_id
  private_access_settings_name = "Private Access Settings for ${var.vpc_id}"
  region                       = var.region
  public_access_enabled        = true
  allowed_vpc_endpoint_ids     = [databricks_mws_vpc_endpoint.this["rest"].vpc_endpoint_id]
  private_access_level         = "ENDPOINT"
}