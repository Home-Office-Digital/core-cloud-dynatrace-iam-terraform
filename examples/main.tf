module "example" {
  source = "../"
  groups_and_permissions = {
    group_one = {
      group_description = "Group one description"
      fedarated_attribute_values = [
        "SomeEntraGroup"
      ]
      attached_policies = {
        policy_static = {
          tvy38111 = {
            policy_boundary = "environment:management-zone startsWith \"[Foo]\";"
          }
          abc12345 = {}
          xyz67890 = {}
        }
        # Can also attach existing policy
        "Admin User" = {}
      }
    }
    group_two = {
      group_description = "Group two description"
      attached_policies = {
        policy_with_param = {
          tvy38111 = {
            policy_parameters = {
              zone = "zone1"
            }
            policy_metadata = {
              meta1 = "metaval1"
            }
          }
        }
      }
    }
    # A group with no environment-scoped policies, used purely to grant
    # account-level built-in permissions via account_permissions below.
    group_three = {
      group_description = "Group three description"
      federated_attribute_values = [
        "SomeOtherEntraGroup"
      ]
    }
    # A local (non-federated) group: no federated_attribute_values, so it isn't
    # tied to a SAML/SCIM identity provider claim. Service users - which have no
    # SSO identity of their own - are typically assigned to groups like this one.
    group_four = {
      group_description = "Group four description - local group for service user membership"
    }
  }

  # Grants built-in dynatrace_iam_permission entries at the account level.
  # See https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/iam_permission
  account_permissions = {
    group_three = ["account-viewer"]
  }

  # Service users, optionally assigned to any local (non-federated) group defined above.
  # See https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/iam_service_user
  service_users = {
    "example-service-user" = {
      description = "A service user for testing purposes"
      groups      = ["group_four"]
    }
  }

  iam_policies = {
    policy_with_param = {
      policy_description = "My IAM policy_with_param description"
      policy_statement   = <<EOT
        ALLOW environment:roles:viewer, environment:roles:manage-settings
        WHERE environment:management-zone IN ("zone2", "$${bindParam:my-policy-param}");

        EOT
    }
    policy_static = {
      policy_description = "My IAM policy_static description"
      policy_statement   = <<EOT
        ALLOW settings:objects:read;

      EOT
    }
  }

  accountUUID = "a8c6fb99-cc30-46b5-9306-1111111"
}

terraform {
  required_providers {
    dynatrace = {
      version = "~> 1.0"
      source  = "dynatrace-oss/dynatrace"
    }
  }
}
