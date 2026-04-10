locals {
  account_ou_mapping = {
    security_tooling = "security"
    log_archive      = "security"
    shared_services  = "infrastructure"
    production_app1  = "production"
    development_app1 = "development"
  }

  ou_ids = {
    security       = aws_organizations_organizational_unit.security.id
    infrastructure = aws_organizations_organizational_unit.infrastructure.id
    production     = aws_organizations_organizational_unit.production.id
    development    = aws_organizations_organizational_unit.development.id
  }
}

resource "aws_organizations_account" "this" {
  count = var.create_accounts ? length(var.account_emails) : 0

  name      = keys(var.account_emails)[count.index]
  email     = var.account_emails[keys(var.account_emails)[count.index]]
  parent_id = local.ou_ids[local.account_ou_mapping[keys(var.account_emails)[count.index]]]

  iam_user_access_to_billing = "DENY"
  role_name                  = "OrganizationAccountAccessRole"

  lifecycle {
    ignore_changes = [role_name, iam_user_access_to_billing]
  }
}
