resource "databricks_workspace_conf" "this" {
  custom_config = var.custom_config

  provider = databricks.workspace
}

resource "databricks_ip_access_list" "allowed-list" {
  label        = "allow_in"
  list_type    = "ALLOW"
  ip_addresses = flatten([for v in values(var.ip_addresses) : v])

  provider   = databricks.workspace
  depends_on = [databricks_workspace_conf.this]
}
