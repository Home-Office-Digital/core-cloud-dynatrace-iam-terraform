// TEST: `local.iam_policies` ternary (mock_dynatrace_calls = false branch) must plan
// cleanly when the data source returns a different number of policies than the number
// of dynatrace_iam_policy resources being created (real-world shape).
// Why: a previous version of this expression mixed raw resource/data-source objects of
// differing attribute shapes and lengths across the two ternary branches, which
// Terraform rejects with "Inconsistent conditional result types" once both branches
// hold real values - regression coverage for that, using override_data to simulate
// the API response offline (mock_dynatrace_calls only stubs the count/provider call,
// not the type-checking path, so this cannot be caught by mock_dynatrace_calls alone).

provider "dynatrace" {}

test {}

variables {
  accountUUID            = "00000000-0000-0000-0000-000000000000"
  mock_dynatrace_calls   = false
  groups_and_permissions = {}
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
}

override_data {
  target = data.dynatrace_iam_policies.allPolicies[0]
  values = {
    policies = [
      {
        id          = "existing-1"
        uuid        = "uuid-1"
        name        = "Existing Policy 1"
        account     = "00000000-0000-0000-0000-000000000000"
        environment = ""
        global      = false
      },
      {
        id          = "existing-2"
        uuid        = "uuid-2"
        name        = "Existing Policy 2"
        account     = "00000000-0000-0000-0000-000000000000"
        environment = ""
        global      = false
      },
      {
        id          = "existing-3"
        uuid        = "uuid-3"
        name        = "Existing Policy 3"
        account     = "00000000-0000-0000-0000-000000000000"
        environment = ""
        global      = false
      },
      {
        id          = "existing-4"
        uuid        = "uuid-4"
        name        = "Existing Policy 4"
        account     = "00000000-0000-0000-0000-000000000000"
        environment = ""
        global      = false
      },
      {
        id          = "existing-5"
        uuid        = "uuid-5"
        name        = "Existing Policy 5"
        account     = "00000000-0000-0000-0000-000000000000"
        environment = ""
        global      = false
      }
    ]
  }
}

run "plan_with_real_branch" {
  command = plan

  assert {
    condition     = length(local.iam_policies) == 7
    error_message = "Expected local.iam_policies to combine 5 existing + 2 new policies"
  }
}
