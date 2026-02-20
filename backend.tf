terraform {
  backend "s3" {
    bucket       = "terraform-state-secure-aws-env"
    key          = "terraform.tfstate"
    region       = "eu-west-3"
    use_lockfile = true
  }
}