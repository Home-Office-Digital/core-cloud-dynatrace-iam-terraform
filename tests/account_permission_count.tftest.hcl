// TEST: Assert planned number of `dynatrace_iam_permission` resources equals the flattened size of `account_permissions` (plan-only)
// Why: prevents regressions in account-level permission wiring and ensures tests run offline by skipping provider lookups.

provider "dynatrace" {}

test {}

variables {
  accountUUID          = "00000000-0000-0000-0000-000000000000"
  iam_policies         = {}
  mock_dynatrace_calls = true
  groups_and_permissions = {
    "account-access-group" = {
      group_description = "Account access group"
      federated_attribute_values = [
        "SomeEntraGroup"
      ]
    }
  }
  account_permissions = {
    "account-access-group" = ["account-viewer"]
  }
}

run "plan_capture" {
  command = plan
}

run "assert_account_permission_count" {
  command = plan

  assert {
    condition     = run.plan_capture.planned_account_permission_count == 1
    error_message = "Expected 1 dynatrace_iam_permission resource to be planned"
  }

  assert {
    condition     = dynatrace_iam_permission.account_permissions["account-access-group.account-viewer"].name == "account-viewer"
    error_message = "Expected the planned permission's name to be account-viewer"
  }

  assert {
    condition     = dynatrace_iam_permission.account_permissions["account-access-group.account-viewer"].account == var.accountUUID
    error_message = "Expected the planned permission to be scoped to var.accountUUID"
  }

  assert {
    condition     = dynatrace_iam_group.cc-iam-group["account-access-group"].federated_attribute_values == toset(["SomeEntraGroup"])
    error_message = "Expected the target group's federated_attribute_values to match the configured Entra group"
  }

  # Note: we cannot assert `dynatrace_iam_permission.account_permissions[...].group ==
  # dynatrace_iam_group.cc-iam-group[...].id` here - both sides are provider-computed and
  # unknown until apply, so this would require `command = apply` against a real (or fully
  # mocked) provider, which this offline test suite intentionally does not do.
}
