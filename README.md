# What does the repository do?

This repository creates the following resources:

1. Dynatrace IAM groups
2. Dynatrace IAM policies
3. Bindings of the policies - both predefined and custom - to the created/configured groups.
4. Built-in `dynatrace_iam_permission` grants (e.g. `account-viewer`) to a group at the account level, via the `account_permissions` input.
5. Dynatrace IAM service users, optionally assigned to groups created by this module, via the `service_users` input. Group membership is only meaningful for local (non-federated) groups, since service users have no SSO identity to federate.

# What is not implemented?

1. As required in the ticket, boundaries will not be created by the repository as the functionality is not available through code.
2. Policies are not created with environment scope as it is a deprecated functionality (as per the [terraform documentation](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/iam_policy)). However, the functionality could be achieved through policy statement condition.

# Inputs

Please refer to [variables.tf](variables.tf) for details on the input variables.

# Outputs

Please refer to [outputs.tf](outputs.tf) for details on the output values.
<!-- BEGIN_TF_DOCS -->
<!-- NOTE: this block is maintained by hand (terraform-docs is not wired up in this repo's
     pre-commit config) - keep it in sync with variables.tf/outputs.tf/main.tf when they change. -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_dynatrace"></a> [dynatrace](#requirement\_dynatrace) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_dynatrace"></a> [dynatrace](#provider\_dynatrace) | ~> 1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [dynatrace_iam_group.cc-iam-group](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/iam_group) | resource |
| [dynatrace_iam_permission.account_permissions](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/iam_permission) | resource |
| [dynatrace_iam_policy.env_policy](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/iam_policy) | resource |
| [dynatrace_iam_policy_bindings_v2.cc-policy-bindings](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/iam_policy_bindings_v2) | resource |
| [dynatrace_iam_policy_boundary.boundaries](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/iam_policy_boundary) | resource |
| [dynatrace_iam_service_user.cc-service-user](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/iam_service_user) | resource |
| [dynatrace_iam_policies.allPolicies](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/data-sources/iam_policies) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accountUUID"></a> [accountUUID](#input\_accountUUID) | Root account UUID | `string` | n/a | yes |
| <a name="input_groups_and_permissions"></a> [groups\_and\_permissions](#input\_groups\_and\_permissions) | Map containing group name, federated values and policy attachment configuration | see [variables.tf](variables.tf) | `{}` | no |
| <a name="input_iam_policies"></a> [iam\_policies](#input\_iam\_policies) | Map of policy names and their policy query statement. | see [variables.tf](variables.tf) | `{}` | no |
| <a name="input_account_permissions"></a> [account\_permissions](#input\_account\_permissions) | Map of group name (must be a key in groups\_and\_permissions) to a list of built-in dynatrace\_iam\_permission names to grant that group at the account level. | `map(list(string))` | `{}` | no |
| <a name="input_service_users"></a> [service\_users](#input\_service\_users) | Map of service user name to its description and the group names (must be keys in groups\_and\_permissions) it belongs to. Referenced groups must be local (no federated\_attribute\_values). | see [variables.tf](variables.tf) | `{}` | no |
| <a name="input_mock_dynatrace_calls"></a> [mock\_dynatrace\_calls](#input\_mock\_dynatrace\_calls) | Test-only: when true, skip Dynatrace provider/data calls for local unit tests. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_planned_policy_count"></a> [planned\_policy\_count](#output\_planned\_policy\_count) | Count of iam\_policy resources planned from iam\_policies input |
| <a name="output_planned_account_permission_count"></a> [planned\_account\_permission\_count](#output\_planned\_account\_permission\_count) | Count of dynatrace\_iam\_permission resources planned from account\_permissions input |
| <a name="output_planned_service_user_count"></a> [planned\_service\_user\_count](#output\_planned\_service\_user\_count) | Count of dynatrace\_iam\_service\_user resources planned from service\_users input |
<!-- END_TF_DOCS -->