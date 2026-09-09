output "planned_policy_count" {
  value       = length(dynatrace_iam_policy.env_policy)
  description = "Count of iam_policy resources planned from iam_policies input"
}

output "planned_account_permission_count" {
  value       = length(dynatrace_iam_permission.account_permissions)
  description = "Count of dynatrace_iam_permission resources planned from account_permissions input"
}

output "planned_service_user_count" {
  value       = length(dynatrace_iam_service_user.cc-service-user)
  description = "Count of dynatrace_iam_service_user resources planned from service_users input"
}