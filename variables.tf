variable "groups_and_permissions" {
  type = map(object({
    # Refer to :
    #   https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/iam_group#federated_attribute_values-1
    # and
    #   https://docs.dynatrace.com/docs/manage/identity-access-management/user-and-group-management/access-group-management
    # for more details
    federated_attribute_values = optional(list(string))
    # Refer to https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/iam_policy_bindings_v2 and
    # https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/iam_policy
    # for more details.
    # Please note that 'environment' is deprecated from the 'iam_policy'
    # resource and therefore not supported here - only 'account' is supported
    # For documentation on parameters refer to:
    #   https://docs.dynatrace.com/docs/manage/identity-access-management/permission-management/manage-user-permissions-policies/advanced/iam-policy-templating
    attached_policies = optional(map(map(object({
      policy_parameters = optional(map(string), null)
      policy_metadata   = optional(map(string), null)
      policy_boundary   = optional(string, null)
    }))), {})
    group_description = string
  }))
  description = "Map containing group name, federated values and policy attachment configuration"
  default     = {}
}

variable "accountUUID" {
  type        = string
  description = "Root account UUID"
}


# Refer to https://docs.dynatrace.com/docs/manage/identity-access-management/permission-management/manage-user-permissions-policies/advanced/iam-policystatements
variable "iam_policies" {
  type = map(object({
    policy_statement   = string
    policy_description = string
  }))
  description = "Map of policy names and their policy query statement."
  default     = {}
}


// Refer to https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/iam_permission
variable "account_permissions" {
  type        = map(list(string))
  description = "Map of group name (must be a key in groups_and_permissions) to a list of built-in dynatrace_iam_permission names to grant that group at the account level, e.g. { my_group = [\"account-viewer\"] }."
  default     = {}
}

// testability: add a single explicit test-only flag
variable "mock_dynatrace_calls" {
  type        = bool
  description = "When true, skip Dynatrace provider/data calls for local unit tests (test-only)."
  default     = false
}

// Refer to https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/iam_service_user
variable "service_users" {
  type = map(object({
    description = optional(string)
    groups      = optional(list(string), [])
  }))
  description = "Map of service user name to its description and the group names (must be keys in groups_and_permissions) it belongs to."
  default     = {}
}

