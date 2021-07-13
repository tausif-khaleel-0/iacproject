locals {
  policy_filename   = var.policy_type == "saas" ? "client_policy.json" : "client_to_orca_policy.json"
  policy_name       = var.policy_type == "saas" ? "OrcaSecurityPolicy" : "OrcaSecurityPolicySA"
  role_name         = var.policy_type == "saas" ? "OrcaSecurityRole"   : "OrcaSecurityRoleSA"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "role" {
  name = local.role_name
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Action: "sts:AssumeRole",
        Principal: {
          AWS: "arn:aws:iam::${var.vendor_account_id}:root"
        },
        Condition: {
          StringEquals: {
            "sts:ExternalId": var.role_external_id
          }
        },
        Effect: "Allow",
        Sid: ""
      }
    ]
  })
}

resource "aws_iam_policy" "policy" {
  policy      = file("${path.module}/${local.policy_filename}")
  name        = local.policy_name
  description = "Orca Security Account Policy"
}

resource "aws_iam_policy" "secrets_manager_policy" {
  count       = var.secrets_manager_access ? 1 : 0
  name        = "OrcaSecuritySecretsManagerPolicy"
  description = "Orca Security Secrets Manager Policy"
  policy      = file("${path.module}/client_secrets_manager_policy.json")
}

resource "aws_iam_role_policy_attachment" "orca-attach" {
  role        = aws_iam_role.role.name
  policy_arn  = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_read_only" {
  role        = aws_iam_role.role.name
  policy_arn  = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "attach_secrets_manager_access" {
  count       = (var.secrets_manager_access && var.policy_type == "saas") ? 1 : 0
  role        = aws_iam_role.role.name
  policy_arn  = aws_iam_policy.secrets_manager_policy[0].arn
}

resource "aws_iam_role" "inaccount-scanner-client" {
  count = (var.policy_type == "inaccount" && var.inaccount_scanner_account_id != null) ? 1 : 0
  name = "OrcaSideScannerRole"
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Action: "sts:AssumeRole",
        Principal: {
          AWS: "arn:aws:iam::${var.inaccount_scanner_account_id}:root"
        },
        Condition: {
          StringEquals: {
            "sts:ExternalId": var.role_external_id
          }
        },
        Effect: "Allow",
        Sid: ""
      }
    ]
  })
}

resource "aws_iam_policy" "inaccount-scanner-client" {
  count       = var.policy_type == "inaccount" ? 1 : 0
  name        = "OrcaSecuritySideScannerPolicy"
  description = "Orca Security Side Scanner Policy"
  policy      = file("${path.module}/client_to_scanner_policy.json")
}

resource "aws_iam_role_policy_attachment" "inaccount-scanner-client" {
  count       = var.policy_type == "inaccount" ? 1 : 0
  role        = aws_iam_role.inaccount-scanner-client[0].name
  policy_arn  = aws_iam_policy.inaccount-scanner-client[0].arn
}

resource "aws_iam_role_policy_attachment" "inaccount-scanner-client-ro" {
  count       = var.policy_type == "inaccount" ? 1 : 0
  role        = aws_iam_role.inaccount-scanner-client[0].name
  policy_arn  = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "inaccount-scanner-client-secrets-manager-access" {
  count       = (var.secrets_manager_access && var.policy_type == "inaccount") ? 1 : 0
  role        = aws_iam_role.inaccount-scanner-client[0].name
  policy_arn  = aws_iam_policy.secrets_manager_policy[0].arn
}
