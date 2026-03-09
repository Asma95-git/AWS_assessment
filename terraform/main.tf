variable "email" {
  description = "Email address for Cognito or user setup"
  type        = string
  default     = "example@example.com"   # test email
}

# US Region Stack
module "stack_us" {
  source           = "./modules/regional_stack"
  region_provider  = aws
  email            = var.email
  github_repo      = var.github_repo
}

# EU Region Stack
module "stack_eu" {
  source           = "./modules/regional_stack"
  region_provider  = aws.secondary
  email            = var.email
  github_repo      = var.github_repo
}