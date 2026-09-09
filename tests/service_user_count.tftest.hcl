// TEST: Assert planned number of `dynatrace_iam_service_user` resources equals the size of
// `service_users` (plan-only), and that the group it's assigned to is local (not SAML/SCIM).
// Why: prevents regressions in service user creation/group-assignment wiring and ensures tests
// run offline by skipping provider lookups.

provider "dynatrace" {}

test {}

variables {
  accountUUID          = "00000000-0000-0000-0000-000000000000"
  iam_policies         = {}
  mock_dynatrace_calls = true
  groups_and_permissions = {
    "local-group" = {
      group_description = "Local group for service user membership"
    }
  }
  service_users = {
    "my-service-user" = {
      description = "A service user for testing purposes"
      groups      = ["local-group"]
    }
  }
}

run "plan_capture" {
  command = plan
}

run "assert_service_user_count" {
  command = plan

  # Overriding the group's id to a known value makes the service user's derived `groups` set
  # known during plan too, so we can assert on its actual membership below instead of just its
  # length (dynatrace_iam_group.cc-iam-group[...].id is otherwise unknown until apply, same
  # limitation noted in account_permission_count.tftest.hcl).
  override_resource {
    target          = dynatrace_iam_group.cc-iam-group["local-group"]
    override_during = plan
    values = {
      id = "00000000-0000-0000-0000-0000000000aa"
    }
  }

  assert {
    condition     = run.plan_capture.planned_service_user_count == 1
    error_message = "Expected 1 dynatrace_iam_service_user resource to be planned"
  }

  assert {
    condition     = dynatrace_iam_service_user.cc-service-user["my-service-user"].name == "my-service-user"
    error_message = "Expected the planned service user's name to be my-service-user"
  }

  assert {
    condition     = dynatrace_iam_service_user.cc-service-user["my-service-user"].description == "A service user for testing purposes"
    error_message = "Expected the planned service user's description to match the configured value"
  }

  assert {
    condition     = dynatrace_iam_group.cc-iam-group["local-group"].federated_attribute_values == null
    error_message = "Expected the target group to be local (no federated_attribute_values), i.e. not SAML/SCIM-bound"
  }

  assert {
    condition     = dynatrace_iam_service_user.cc-service-user["my-service-user"].groups == toset(["00000000-0000-0000-0000-0000000000aa"])
    error_message = "Expected the planned service user to be assigned to local-group's (overridden) group ID"
  }
}

// TEST: A service user referencing a federated (SAML/SCIM) group must fail to plan.
// Why: service users have no SSO identity to federate; the lifecycle.precondition on
// dynatrace_iam_service_user.cc-service-user (main.tf) must hard-block this, not just warn.
run "assert_federated_group_rejected" {
  command = plan

  variables {
    groups_and_permissions = {
      "local-group" = {
        group_description = "Local group for service user membership"
      }
      "federated-group" = {
        group_description = "Federated group"
        federated_attribute_values = [
          "SomeEntraGroup"
        ]
      }
    }
    service_users = {
      "my-service-user" = {
        description = "A service user for testing purposes"
        groups      = ["federated-group"]
      }
    }
  }

  expect_failures = [
    dynatrace_iam_service_user.cc-service-user,
  ]
}
