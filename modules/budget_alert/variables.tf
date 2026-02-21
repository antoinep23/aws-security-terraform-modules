variable "budget_limit" {
  description = "The amount of the budget limit."
  type        = string
}

variable "subscriber_email_addresses" {
  description = "The email addresses to receive budget notifications."
  type        = list(string)
}