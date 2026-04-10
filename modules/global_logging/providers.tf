terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  alias  = "log_archive"
  region = "eu-west-3"
  assume_role {
    role_arn = "arn:aws:iam::${var.log_archive_account_id}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "security_tooling"
  region = "eu-west-3"
  assume_role {
    role_arn = "arn:aws:iam::${var.security_tooling_account_id}:role/OrganizationAccountAccessRole"
  }
}