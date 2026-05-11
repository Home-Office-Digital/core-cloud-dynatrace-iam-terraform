output "planned_policy_count" {
  value       = length(dynatrace_iam_policy.env_policy)
  description = "Count of iam_policy resources planned from iam_policies input"
}