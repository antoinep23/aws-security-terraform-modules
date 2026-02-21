module "global_logging" {
  source                         = "./modules/global_logging"
  is_organization_trail          = false
  is_multi_region_trail          = true
  is_encrypted_with_kms          = false
  is_s3_access_logging_enabled   = false
  is_object_lock_enabled         = false
  is_cloudwatch_logs_forwarded   = false
  sns_subscriber_email_addresses = ["security@example.com"] # Need is_cloudwatch_logs_forwarded set to true to deliver alerts
}

module "budget_alert" {
  source                     = "./modules/budget_alert"
  budget_limit               = "10" # USD
  subscriber_email_addresses = ["test@example.com", "test2@example.com"]
}