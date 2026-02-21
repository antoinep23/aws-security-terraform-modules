resource "aws_s3_bucket" "this" {
  bucket        = "cloudtrail-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "MoveCloudTrailLogsToGlacier"
    status = "Enabled"

    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = var.is_object_lock_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 365
    }
  }
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.this.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:trail/GlobalTrail"]
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
    resources = ["${aws_s3_bucket.this.arn}/AWSLogs/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:trail/GlobalTrail"]
    }
  }
}

# CloudTrail access logging

resource "aws_s3_bucket" "logging" {
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
  count  = var.is_s3_access_logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.logging[0].bucket
  policy = data.aws_iam_policy_document.logging_bucket_policy[0].json
}

resource "aws_s3_bucket_logging" "this" {
  count  = var.is_s3_access_logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.bucket

  target_bucket = aws_s3_bucket.logging[0].bucket
  target_prefix = "logs/"
  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "EventTime"
    }
  }
}

resource "aws_s3_bucket_versioning" "logging" {
  count  = var.is_s3_access_logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.logging[0].id

  versioning_configuration {
    status = "Enabled"
  }
}