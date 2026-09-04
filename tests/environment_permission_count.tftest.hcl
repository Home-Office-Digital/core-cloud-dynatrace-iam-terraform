provider "dynatrace" {}

test {}

variables {
  accountUUID          = "00000000-0000-0000-0000-000000000000"
  iam_policies         = {}
  mock_dynatrace_calls = true
  groups_and_permissions = {
    "environment-admin-group" = {
      group_description = "Environment admin group"
      federated_attribute_values = [
        "SomeEntraGroup"
      ]
    }
  }
  environment_permissions = {
    "environment-admin-group" = {
      tenant-manage-support-tickets = [
        "nuh63189",
        "ewo35763",
        "kvm79295",
        "vir21829"
      ]
    }
  }
}

run "plan_environment_permissions" {
  command = plan

  assert {
    condition     = length(dynatrace_iam_permission.environment_permissions) == 4
    error_message = "Expected four support-ticket permissions to be planned"
  }

  assert {
    condition     = alltrue([for permission in values(dynatrace_iam_permission.environment_permissions) : permission.name == "tenant-manage-support-tickets"])
    error_message = "Expected all planned permissions to manage support tickets"
  }

  assert {
    condition     = toset([for permission in values(dynatrace_iam_permission.environment_permissions) : permission.environment]) == toset(["nuh63189", "ewo35763", "kvm79295", "vir21829"])
    error_message = "Expected support-ticket permissions in the four configured environments"
  }
}