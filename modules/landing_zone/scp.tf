resource "aws_organizations_policy" "deny_root_user" {
  name        = "DenyRootUser"
  description = "Deny all actions for root user in member accounts"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyRootUser"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::*:root"
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "deny_root_user_attachment" {
  policy_id = aws_organizations_policy.deny_root_user.id
  target_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_policy" "region_restriction" {
  name        = "RegionRestriction"
  description = "Restrict actions to regions: ${join(", ", var.allowed_regions)}"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "RegionRestriction"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.allowed_regions
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "region_restriction_attachment" {
  policy_id = aws_organizations_policy.region_restriction.id
  target_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_policy" "deny_leave_organization" {
  name        = "DenyLeaveOrganization"
  description = "Deny the ability for member accounts to leave the organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyLeaveOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "deny_leave_organization_attachment" {
  policy_id = aws_organizations_policy.deny_leave_organization.id
  target_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_policy" "deny_public_s3_buckets" {
  name        = "DenyPublicS3Buckets"
  description = "Deny the ability to create or modify S3 buckets with public access"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyPublicS3Buckets"
        Effect = "Deny"
        Action = [
          "s3:PutBucketPublicAccessBlock",
          "s3:PutAccountPublicAccessBlock",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "deny_public_s3_buckets_attachment" {
  policy_id = aws_organizations_policy.deny_public_s3_buckets.id
  target_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_policy" "protect_security_services" {
  name        = "ProtectSecurityServices"
  description = "Deny the ability to delete or modify security-related services"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ProtectSecurityServices"
        Effect = "Deny"
        Action = [
          "guardduty:DeleteDetector",
          "guardduty:StopMonitoring",
          "securityhub:Delete*",
          "iamaccessanalyzer:DeleteAnalyzer",
        ]
        Resource = "*"
        }, {
        Sid    = "ProtectCloudTrail"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
        ]
        Resource = var.cloudtrail_trail_arn
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "protect_security_services_attachment" {
  policy_id = aws_organizations_policy.protect_security_services.id
  target_id = aws_organizations_organizational_unit.security.id
}

resource "aws_organizations_policy" "suspended_accounts" {
  name        = "SuspendedAccounts"
  description = "Deny everything for accounts in the Suspended OU"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "SuspendedAccounts"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "suspended_accounts_attachment" {
  policy_id = aws_organizations_policy.suspended_accounts.id
  target_id = aws_organizations_organizational_unit.suspended.id
}