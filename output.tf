output "orca_role_arn" {
    description = "Role ARN to be used to onboard"
    value = aws_iam_role.role.arn
}

output "orca_role_external_id" {
    description = "The role External ID"
    value = var.role_external_id
}

output "customer_account_id" {
    description = "This is the account id to be used for onboarding the account"
    value = data.aws_caller_identity.current.account_id
}

output "sidescanner_role_arn" {
    description = "The role ARN of the sidescanner. (In case of inaccount policy type)"
    value = var.policy_type == "inaccount" ? aws_iam_role.inaccount-scanner-client[0].arn : "N/A"
}
