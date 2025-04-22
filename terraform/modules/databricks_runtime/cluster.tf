resource "databricks_cluster" "this" {
  for_each = { for cluster in var.clusters : cluster.cluster_name => cluster }

  cluster_name            = each.value.cluster_name
  spark_version           = each.value.spark_version
  node_type_id            = each.value.node_type_id
  autotermination_minutes = each.value.autotermination_minutes
  autoscale {
    min_workers = each.value.min_workers
    max_workers = each.value.max_workers
  }

  aws_attributes {
    availability           = each.value.availability
    zone_id                = each.value.zone_id
    first_on_demand        = each.value.first_on_demand
    spot_bid_price_percent = each.value.spot_bid_price_percent
  }

  provider = databricks.workspace
}
