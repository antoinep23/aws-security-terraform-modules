variable "account_emails" {
  type        = map(string)
  description = "Map of email addresses for AWS accounts"
}

variable "create_accounts" {
  type        = bool
  description = "Whether to create AWS accounts or not"
  default     = false
}

variable "allowed_regions" {
  type        = list(string)
  description = "List of allowed AWS regions"
  default     = ["us-east-1"]
}

variable "cloudtrail_trail_arn" {
  type        = string
  description = "ARN of the global logging CloudTrail trail"
  default     = ""
}

variable "management_account_id" {
  type        = string
  description = "AWS Account ID of the management account"
}