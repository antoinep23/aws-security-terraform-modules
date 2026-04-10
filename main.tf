module "global_logging" {
  source                       = "./modules/global_logging"
  is_organization_trail        = true
  is_multi_region_trail        = true
  is_encrypted_with_kms        = false
  is_s3_access_logging_enabled = false
  is_object_lock_enabled       = false
  is_cloudwatch_logs_forwarded = false

  log_archive_account_id      = module.landing_zone.accounts_ids["log_archive"]
  security_tooling_account_id = module.landing_zone.accounts_ids["security_tooling"]
  management_account_id       = local.management_account_id

  sns_subscriber_email_addresses = [local.sns_subscriber_email]
}

module "budget_alert" {
  source                     = "./modules/budget_alert"
  budget_limit_usd           = "10"
  subscriber_email_addresses = [local.sns_subscriber_email]
}

module "landing_zone" {
  source          = "./modules/landing_zone"
  create_accounts = true
  base_email      = local.base_email
  account_emails = {
    security_tooling = "${local.base_email}+security-tooling-2@gmail.com",
    log_archive      = "${local.base_email}+log-archive-2@gmail.com",
    # shared_services  = "${local.base_email}+shared-services-2@gmail.com",
    # production_app1  = "${local.base_email}+production-app1-2@gmail.com",
    # development_app1 = "${local.base_email}+development-app1-2@gmail.com"
  }
  allowed_regions       = ["eu-west-3", "us-east-1"]
  management_account_id = local.management_account_id
  cloudtrail_trail_arn  = module.global_logging.cloudtrail_logging_trail_arn
}