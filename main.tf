locals {
  policy_filename   = var.policy_type == "saas" ? "saas/client_policy.json.tpl" : "scanneraccount/client_to_orca_policy.json.tpl"
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
  policy      = templatefile("${path.module}/policies/${local.policy_filename}", { partition = var.aws_partition })
  name        = local.policy_name
  description = "Orca Security Account Policy"
}

resource "aws_iam_policy" "view_only_extras_policy" {
  policy      = file("${path.module}/policies/view_only_extras_policy.json")
  name        = "OrcaSecurityViewOnlyExtrasPolicy"
  description = "Orca Security Extras For View Only Policy"
}

resource "aws_iam_policy" "secrets_manager_policy" {
  count       = var.secrets_manager_access ? 1 : 0
  name        = "OrcaSecuritySecretsManagerPolicy"
  description = "Orca Security Secrets Manager Policy"
  policy      = file("${path.module}/policies/client_secrets_manager_policy.json")
}

resource "aws_iam_role_policy_attachment" "orca-attach" {
  role        = aws_iam_role.role.name
  policy_arn  = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_view_only" {
  role        = aws_iam_role.role.name
  policy_arn  = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "attach_view_only_extras" {
  role        = aws_iam_role.role.name
  policy_arn  = aws_iam_policy.view_only_extras_policy.arn
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
  policy      = templatefile("${path.module}/policies/scanneraccount/client_to_scanner_policy.json.tpl", { partition = var.aws_partition })
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
