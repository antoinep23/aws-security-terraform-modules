output "accounts_ids" {
  description = "Map of account names to account IDs"
  value       = zipmap(keys(var.account_emails), aws_organizations_account.this[*].id)
}
