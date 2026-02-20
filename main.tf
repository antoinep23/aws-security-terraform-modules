module "global_logging" {
  source                       = "./modules/global_logging"
  is_organization_trail        = false
  is_multi_region_trail        = true
  is_encrypted_with_kms        = true
  is_cloudwatch_logs_forwarded = true
}