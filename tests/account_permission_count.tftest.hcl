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
}
