variable "is_organization_trail" {
  description = "Whether to create an organization trail (requires the account to be the management account of an organization)"
  type        = bool
  default     = false
}

variable "is_encrypted_with_kms" {
  description = "Whether to encrypt CloudTrail logs with a KMS key"
  type        = bool
  default     = false
}

variable "is_cloudwatch_logs_forwarded" {
  description = "Whether to forward CloudTrail logs to CloudWatch Logs"
  type        = bool
  default     = false
}

variable "is_multi_region_trail" {
  description = "Whether to create a multi-region trail"
  type        = bool
  default     = false
}

variable "is_s3_access_logging_enabled" {
  description = "Whether to enable S3 access logging for the CloudTrail logs bucket"
  type        = bool
  default     = false
}

variable "is_object_lock_enabled" {
  description = "Whether to enable S3 Object Lock for the CloudTrail logs bucket"
  type        = bool
  default     = false
}

variable "sns_subscriber_email_addresses" {
  description = "List of email addresses to subscribe to the SNS topic for CloudTrail alerts"
  type        = list(string)
  default     = []
}

variable "log_archive_account_id" {
  description = "The account ID of the log archive account"
  type        = string
}

variable "security_tooling_account_id" {
  description = "The account ID of the security tooling account"
  type        = string
}

variable "management_account_id" {
  type        = string
  description = "AWS Account ID of the management account"
}