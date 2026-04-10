variable "budget_limit_usd" {
  description = "The amount of the budget limit in USD."
  type        = string
}

variable "subscriber_email_addresses" {
  description = "The email addresses to receive budget notifications."
  type        = list(string)
}