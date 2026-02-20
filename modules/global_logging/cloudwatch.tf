resource "aws_cloudwatch_log_group" "this" {
  name                        = "CloudTrail/GlobalTrail"
  retention_in_days           = 30
  kms_key_id                  = var.is_encrypted_with_kms ? aws_kms_key.this[0].arn : null
  deletion_protection_enabled = true
}

resource "aws_iam_role" "this" {
  count = var.is_cloudwatch_logs_forwarded ? 1 : 0
  name  = "CloudTrail_CloudWatchLogs_Role"

  assume_role_policy = data.aws_iam_policy_document.cloudwatch_logs_assume_role[0].json
}

resource "aws_iam_role_policy" "this" {
  count  = var.is_cloudwatch_logs_forwarded ? 1 : 0
  name   = "CloudTrailToCloudWatchPermissions"
  role   = aws_iam_role.this[0].id
  policy = data.aws_iam_policy_document.cloudwatch_logs_permissions[0].json
}

data "aws_iam_policy_document" "cloudwatch_logs_permissions" {
  count = var.is_cloudwatch_logs_forwarded ? 1 : 0
  
  statement {
    sid    = "WriteCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.this.arn}:*"]
  }
}

data "aws_iam_policy_document" "cloudwatch_logs_assume_role" {
  count = var.is_cloudwatch_logs_forwarded ? 1 : 0
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
