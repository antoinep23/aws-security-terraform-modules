locals {
  account_ou_mapping = {
    security_tooling = "security"
    log_archive      = "security"
    shared_services  = "shared_services"
    production_app1  = "production"
    development_app1 = "development"
  }

  ou_ids = {
    security        = aws_organizations_organizational_unit.security.id
    shared_services = aws_organizations_organizational_unit.shared_services.id
    production      = aws_organizations_organizational_unit.production.id
    development     = aws_organizations_organizational_unit.development.id
  }
}

resource "aws_organizations_account" "this" {
  for_each = var.account_emails

  name      = each.key
  email     = var.account_emails[each.key]
  parent_id = local.ou_ids[local.account_ou_mapping[each.key]]

  iam_user_access_to_billing = "DENY"
  role_name                  = "OrganizationAccountAccessRole"

  lifecycle {
    ignore_changes = [role_name, iam_user_access_to_billing]
  }
}
