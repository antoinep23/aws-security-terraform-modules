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
  source = "./modules/landing_zone"
  account_emails = {
    security_tooling = "awssandbox+security-tooling@gmail.com",
    log_archive      = "awssandbox+log-archive@gmail.com",
    shared_services  = "awssandbox+shared-services@gmail.com",
    production_app1  = "awssandbox+production-app1@gmail.com",
    development_app1 = "awssandbox+development-app1@gmail.com"
  }
}