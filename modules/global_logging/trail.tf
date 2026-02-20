resource "aws_cloudtrail" "this" {
  depends_on = [aws_s3_bucket_policy.this]

  name           = "GlobalTrail"
  s3_bucket_name = aws_s3_bucket.this.id

  include_global_service_events = true
  enable_log_file_validation    = true

  is_multi_region_trail = var.is_multi_region_trail ? true : false
  kms_key_id            = var.is_encrypted_with_kms ? aws_kms_key.this[0].arn : null
  is_organization_trail = var.is_organization_trail

  cloud_watch_logs_role_arn  = var.is_cloudwatch_logs_forwarded ? aws_iam_role.this[0].arn : null
  cloud_watch_logs_group_arn = var.is_cloudwatch_logs_forwarded ? "${aws_cloudwatch_log_group.this.arn}:*" : null
}
