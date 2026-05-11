# Verify that the module creates exactly the number of iam_policy resources corresponding to iam_policies input

provider "dynatrace" {}

test {}

variables {
  accountUUID = "00000000-0000-0000-0000-000000000000"
  iam_policies = {
    "policy-a" = {
      policy_statement   = "ALLOW x"
      policy_description = "a"
    }
    "policy-b" = {
      policy_statement   = "ALLOW y"
      policy_description = "b"
    }
  }
  mock_dynatrace_calls = true
  groups_and_permissions = {}
}

run "plan_capture" {
  command = plan
}

run "assert_policy_count" {
  command = plan

  assert {
    condition = run.plan_capture.planned_policy_count == 2
    error_message = "Expected 2 iam_policy resources to be planned"
  }
}
