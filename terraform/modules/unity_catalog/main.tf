# Metastore grants
locals {
  mapped_metastore_grants = {
    for object in var.metastore_grants : object.principal => object
    if object.principal != null
  }
}

resource "databricks_grants" "metastore" {
  count = length(local.mapped_metastore_grants) != 0 ? 1 : 0

  metastore = var.metastore_id
  dynamic "grant" {
    for_each = local.mapped_metastore_grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}

# Catalog creation
resource "databricks_catalog" "this" {
  for_each = {
    for object in var.catalog : object.catalog_name => object
    if object.catalog_name != null
  }

  metastore_id  = var.metastore_id
  name          = each.value.catalog_name
  owner         = each.value.catalog_owner
  comment       = lookup(each.value, "catalog_comment", "default comment")
  properties    = merge(lookup(each.value, "catalog_properties", {}), { env = var.env })
  force_destroy = true
}

# Catalog grants
resource "databricks_grants" "catalog" {
  for_each = {
    for params in var.catalog : params.catalog_name => params.catalog_grants
    if params.catalog_grants != null
  }

  catalog = databricks_catalog.this[each.key].name
  dynamic "grant" {
    for_each = each.value
    content {
      principal  = grant.key
      privileges = grant.value
    }
  }
}

# Schema creation
locals {
  schema = flatten([
    for params in var.catalog : [
      for schema in params.schema_name : {
        catalog    = params.catalog_name,
        schema     = schema,
        comment    = lookup(params, "schema_comment", "default comment"),
        properties = lookup(params, "schema_properties", {})
        owner      = lookup(params, "schema_owner", null)
      }
    ] if params.schema_name != null
  ])
}

resource "databricks_schema" "this" {
  for_each = {
    for entry in local.schema : "${entry.catalog}.${entry.schema}" => entry
  }

  catalog_name  = databricks_catalog.this[each.value.catalog].name
  name          = each.value.schema
  owner         = each.value.owner
  comment       = each.value.comment
  properties    = merge(each.value.properties, { env = var.env })
  force_destroy = true
}

# Schema grants
locals {
  schema_grants = flatten([
    for params in var.catalog : [for schema in params.schema_name : [for principal in flatten(keys(params.schema_grants)) : {
      catalog    = params.catalog_name,
      schema     = schema,
      principal  = principal,
      permission = flatten(values(params.schema_grants)),
    }]] if params.schema_grants != null
  ])
}

resource "databricks_grants" "schema" {
  for_each = {
    for entry in local.schema_grants : "${entry.catalog}.${entry.schema}.${entry.principal}" => entry
  }

  schema = databricks_schema.this["${each.value.catalog}.${each.value.schema}"].id
  grant {
    principal  = each.value.principal
    privileges = each.value.permission
  }
}
