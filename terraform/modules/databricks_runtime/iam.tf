locals {
  group_user_combinations = flatten([
    for group in var.workspace_groups : [
      for user in group.group_members : {
        group_name = group.group_name
        user_name  = user
      }
    ]
  ])
}

resource "databricks_group" "this" {
  for_each = toset(compact(var.workspace_groups[*].group_name))

  display_name = each.value

  provider = databricks.workspace
}

resource "databricks_user" "this" {
  for_each = toset(flatten(var.workspace_groups[*].group_members))

  user_name = each.value

  provider = databricks.workspace
}

resource "databricks_group_member" "admin_members" {
  for_each = { for i in local.group_user_combinations : "${i.group_name}-${i.user_name}" => i }

  group_id  = databricks_group.this[each.value.group_name].id
  member_id = databricks_user.this[each.value.user_name].id

  provider   = databricks.workspace
  depends_on = [databricks_group.this, databricks_user.this]
}

resource "databricks_secret_scope" "this" {
  name = coalesce(var.databricks_secret_scope_name, "application-secret-scope")

  provider = databricks.workspace
}

resource "databricks_secret_acl" "my_secret_acl" {
  for_each = toset(compact(var.workspace_groups[*].group_name))

  principal  = databricks_group.this[each.key].display_name
  permission = "READ"
  scope      = databricks_secret_scope.this.name

  provider = databricks.workspace
}
