# module "global_logging" {
#   source                         = "./modules/global_logging"
#   is_organization_trail          = false
#   is_multi_region_trail          = true
#   is_encrypted_with_kms          = false
#   is_s3_access_logging_enabled   = false
#   is_object_lock_enabled         = false
#   is_cloudwatch_logs_forwarded   = false
#   sns_subscriber_email_addresses = ["security@example.com"] # Need is_cloudwatch_logs_forwarded set to true to deliver alerts
# }

# module "budget_alert" {
#   source                     = "./modules/budget_alert"
#   budget_limit               = "10" # USD
#   subscriber_email_addresses = ["test@example.com", "test2@example.com"]
# }

module "landing_zone" {
  source          = "./modules/landing_zone"
  create_accounts = false
  account_emails = {
    security_tooling = "awssandbox+security-tooling-2@gmail.com",
    log_archive      = "awssandbox+log-archive-2@gmail.com",
    shared_services  = "awssandbox+shared-services-2@gmail.com",
    production_app1  = "awssandbox+production-app1-2@gmail.com",
    development_app1 = "awssandbox+development-app1-2@gmail.com"
  }
  allowed_regions       = ["eu-west-3"]
  management_account_id = "123456789012"
  # cloudtrail_trail_arn = module.global_logging.cloudtrail_logging_trail_arn
}