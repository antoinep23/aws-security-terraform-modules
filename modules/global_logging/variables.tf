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