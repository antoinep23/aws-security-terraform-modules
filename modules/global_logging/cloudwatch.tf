resource "aws_cloudwatch_log_group" "this" {
  count                       = var.is_cloudwatch_logs_forwarded ? 1 : 0
  name                        = "CloudTrail/GlobalTrail"
  retention_in_days           = 30
  kms_key_id                  = var.is_encrypted_with_kms ? aws_kms_key.this[0].arn : null
  deletion_protection_enabled = false # Need to be set to True
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
    resources = ["${aws_cloudwatch_log_group.this[0].arn}:*"]
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

// Alarm for suspicious CloudTrail events

resource "aws_cloudwatch_log_metric_filter" "this" {
  count          = var.is_cloudwatch_logs_forwarded ? 1 : 0
  name           = "SuspiciousCloudTrailEvents"
  log_group_name = aws_cloudwatch_log_group.this[0].name
  pattern        = "{ ($.eventName = UpdateTrail) || ($.eventName = DeleteTrail) || ($.eventName = StopLogging) }"

  metric_transformation {
    name      = "SuspiciousCloudTrailEventsCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  count               = var.is_cloudwatch_logs_forwarded ? 1 : 0
  alarm_name          = "SuspiciousCloudTrailEventsAlarm"
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Sum"
  threshold           = 0
  evaluation_periods  = 1
  period              = 60
  metric_name         = aws_cloudwatch_log_metric_filter.this[0].metric_transformation[0].name
  alarm_actions       = [aws_sns_topic.this[0].arn]
  namespace           = aws_cloudwatch_log_metric_filter.this[0].metric_transformation[0].namespace
}

resource "aws_sns_topic" "this" {
  count = var.is_cloudwatch_logs_forwarded ? 1 : 0
  name  = "suspicious-cloudtrail-events-topic"
}

resource "aws_sns_topic_subscription" "this" {
  count     = var.is_cloudwatch_logs_forwarded ? length(var.sns_subscriber_email_addresses) : 0
  topic_arn = aws_sns_topic.this[0].arn
  protocol  = "email"
  endpoint  = var.sns_subscriber_email_addresses[count.index]
}