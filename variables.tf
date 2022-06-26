variable "vendor_account_id" {
    description = "The vendor account id. This is supplied by Orca."
    type = string
    default = "976280145156"
}

variable "policy_type" {
    description = "policy type to install (Supported types: saas/inaccount). Default: saas"
    type = string
    default = "saas"
}

variable "inaccount_scanner_account_id" {
    description = "in case of inaccount, the scanner account id"
    type = string
    default = null
}

variable "role_external_id" {
    description = "Role external ID. We will be supplied from Orca."
    type = string
}

variable "secrets_manager_access" {
    description = "Whether to attach SecretsManager policy to Orca's role. Default: true"
    type = bool
    default = true
}

variable "aws_partition" {
    description = "AWS partition (aws / aws-cn / aws-us-gov)"
    type = string
    default = "aws"
    validation {
    condition     = contains(["aws", "aws-cn", "aws-us-gov"], var.aws_partition)
    error_message = "Allowed values for aws_partition are \"aws\", \"aws-cn\", or \"aws-us-gov\"."
  }
}