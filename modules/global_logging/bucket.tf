locals {
  trail_name = "OrganizationGlobalTrail"
}

resource "aws_s3_bucket" "trail" {
  provider      = aws.log_archive
  bucket        = "cloudtrail-logs-${data.aws_organizations_organization.current.id}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "trail" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.trail.id
  policy   = data.aws_iam_policy_document.trail_bucket_policy.json
}

resource "aws_s3_bucket_lifecycle_configuration" "trail" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.trail.id

  rule {
    id     = "MoveCloudTrailLogsToGlacierInstantRetrieval"
    status = "Enabled"

    transition {
      days          = 45
      storage_class = "GLACIER_IR"
    }
  }

  rule {
    id     = "ExpireOldCloudTrailLogs"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_versioning" "trail" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.trail.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "trail" {
  provider = aws.log_archive
  count    = var.is_object_lock_enabled ? 1 : 0
  bucket   = aws_s3_bucket.trail.id

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 365
    }
  }
}

data "aws_iam_policy_document" "trail_bucket_policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.trail.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${data.aws_region.current.region}:${var.management_account_id}:trail/${local.trail_name}"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.trail.arn}/AWSLogs/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${data.aws_region.current.region}:${var.management_account_id}:trail/${local.trail_name}"]
    }
  }

  statement {
    sid    = "AWSCloudTrailOrganizationWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.trail.arn}/AWSLogs/${data.aws_organizations_organization.current.id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${data.aws_region.current.region}:${var.management_account_id}:trail/${local.trail_name}"]
    }
  }
}

# CloudTrail access logging

resource "aws_s3_bucket" "logging" {
  provider      = aws.log_archive
  count         = var.is_s3_access_logging_enabled ? 1 : 0
  bucket        = "cloudtrail-bucket-access-logging${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

data "aws_iam_policy_document" "logging_bucket_policy" {
  count = var.is_s3_access_logging_enabled ? 1 : 0
  statement {
    principals {
      identifiers = ["logging.s3.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logging[0].arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "logging" {
  provider = aws.log_archive
  count    = var.is_s3_access_logging_enabled ? 1 : 0
  bucket   = aws_s3_bucket.logging[0].bucket
  policy   = data.aws_iam_policy_document.logging_bucket_policy[0].json
}

resource "aws_s3_bucket_logging" "this" {
  provider = aws.log_archive
  count    = var.is_s3_access_logging_enabled ? 1 : 0
  bucket   = aws_s3_bucket.trail.bucket

  target_bucket = aws_s3_bucket.logging[0].bucket
  target_prefix = "logs/"
  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "EventTime"
    }
  }
}

resource "aws_s3_bucket_versioning" "logging" {
  provider = aws.log_archive
  count    = var.is_s3_access_logging_enabled ? 1 : 0
  bucket   = aws_s3_bucket.logging[0].id

  versioning_configuration {
    status = "Enabled"
  }
}