# SQL Endpoint
resource "databricks_sql_endpoint" "this" {
  for_each = { for endpoint in var.sql_endpoint : (endpoint.name) => endpoint }

  name                 = each.key
  cluster_size         = each.value.cluster_size
  max_num_clusters     = each.value.max_num_clusters
  enable_photon        = each.value.enable_photon
  spot_instance_policy = each.value.spot_instance_policy
  warehouse_type       = each.value.warehouse_type

  tags {
    custom_tags {
      key   = each.value.key
      value = each.value.value
    }
  }

  provider = databricks.workspace
}

# NOTE: Waiting for resource to get NCC ID
# resource "databricks_mws_ncc_binding" "ncc_binding" {  
#   network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id
#   workspace_id                   = var.databricks_workspace_id

#   provider                       = databricks.account
# }
