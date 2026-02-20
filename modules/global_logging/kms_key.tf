resource "aws_kms_key" "this" {
  count                   = var.is_encrypted_with_kms ? 1 : 0
  description             = "KMS key for CloudTrail logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

}

resource "aws_kms_key_policy" "this" {
  count  = var.is_encrypted_with_kms ? 1 : 0
  key_id = aws_kms_key.this[0].id
  policy = data.aws_iam_policy_document.key[0].json
}

data "aws_iam_policy_document" "key" {
  count = var.is_encrypted_with_kms ? 1 : 0
  statement {
    sid    = "Allow administration of the key"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow use of the key for CloudTrail"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*", "kms:Decrypt"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:trail/GlobalTrail"]
    }
  }

  statement {
    sid    = "Allow use of the key for CloudWatch Logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.region}.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*", "kms:Decrypt", "kms:Encrypt", "kms:ReEncrypt*", "kms:DescribeKey"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}