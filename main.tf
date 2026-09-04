data "dynatrace_iam_policies" "allPolicies" {
  count        = var.mock_dynatrace_calls ? 0 : 1
  environments = ["*"]
  accounts     = ["*"]
  global       = true
}

resource "dynatrace_iam_policy" "env_policy" {
  for_each = var.iam_policies

  name            = each.key
  description     = each.value.policy_description
  account         = var.accountUUID
  statement_query = each.value.policy_statement
}

locals {
  permission_helper = merge(flatten([
    for group_name, group_values in var.groups_and_permissions :
    flatten([
      for policy_name, policy_values in group_values.attached_policies :
      {
        for env_id, env_params in policy_values : "${group_name}.${policy_name}.${env_id}" =>
        {
          "group_name"                 = group_name
          "policy_name"                = policy_name
          "group_description"          = group_values.group_description
          "federated_attribute_values" = group_values.federated_attribute_values
          "env_id"                     = env_id
          "env_params"                 = env_params
        }
      }
    ])
  ])...)

  iam_policies = var.mock_dynatrace_calls ? [for k, v in dynatrace_iam_policy.env_policy : v] : concat(data.dynatrace_iam_policies.allPolicies[0].policies, [for k, v in dynatrace_iam_policy.env_policy : v])
}

resource "dynatrace_iam_group" "cc-iam-group" {
  for_each = var.groups_and_permissions

  name                       = each.key
  description                = each.value.group_description
  federated_attribute_values = each.value.federated_attribute_values

  # dynatrace_iam_permission.account_permissions manages this group's permissions
  # separately; without this, the deprecated `permissions` block on this resource
  # and the dedicated permission resource fight over the same state.
  lifecycle {
    ignore_changes = [permissions]
  }
}

resource "dynatrace_iam_policy_boundary" "boundaries" {
  for_each = {
    for k, v in local.permission_helper : k => v.env_params.policy_boundary if v.env_params.policy_boundary != null
  }

  name  = each.key
  query = each.value

}

locals {
  groupEnvs = { for item in flatten(distinct([for item in local.permission_helper : { group_name = item.group_name, env_id = item.env_id }])) : "${item.group_name}.${item.env_id}" => item }
}

locals {
  account_permission_helper = merge([
    for group_name, perms in var.account_permissions : {
      for perm in perms : "${group_name}.${perm}" => {
        group_name = group_name
        permission = perm
      }
    }
  ]...)
}

check "account_permissions_reference_known_groups" {
  assert {
    condition = alltrue([
      for group_name in keys(var.account_permissions) : contains(keys(var.groups_and_permissions), group_name)
    ])
    error_message = "Every key in account_permissions must also exist as a key in groups_and_permissions."
  }
}

resource "dynatrace_iam_permission" "account_permissions" {
  for_each = local.account_permission_helper

  name    = each.value.permission
  group   = dynatrace_iam_group.cc-iam-group[each.value.group_name].id
  account = var.accountUUID
}

locals {
  environment_permission_helper = merge(flatten([
    for group_name, permissions in var.environment_permissions : [
      for permission, environment_ids in permissions : {
        for environment_id in environment_ids : "${group_name}.${permission}.${environment_id}" => {
          group_name     = group_name
          permission     = permission
          environment_id = environment_id
        }
      }
    ]
  ])...)
}

resource "dynatrace_iam_permission" "environment_permissions" {
  for_each = local.environment_permission_helper

  name        = each.value.permission
  group       = dynatrace_iam_group.cc-iam-group[each.value.group_name].id
  environment = each.value.environment_id
}

resource "dynatrace_iam_policy_bindings_v2" "cc-policy-bindings" {
  for_each = local.groupEnvs

  // dynatrace_iam_policy_bindings_v2 requires a unique resource per group and environment combination
  group       = dynatrace_iam_group.cc-iam-group[each.value.group_name].id
  environment = each.value.env_id

  dynamic "policy" {
    // What this for_each does is look up policy bindings for the specific group and environment
    for_each = [for k, item in local.permission_helper :
    item if item["group_name"] == each.value.group_name && item["env_id"] == each.value.env_id]
    content {
      id         = element([for item in local.iam_policies : item if item["name"] == policy.value.policy_name], 0).id
      parameters = policy.value.env_params != null ? policy.value.env_params.policy_parameters : null
      metadata   = policy.value.env_params != null ? policy.value.env_params.policy_metadata : null
      boundaries = [for item in dynatrace_iam_policy_boundary.boundaries : item.id if item.name == "${policy.value.group_name}.${policy.value.policy_name}.${policy.value.env_id}"] // This looks up whether a boundary exists for the group/policy/env combination
    }
  }
}
