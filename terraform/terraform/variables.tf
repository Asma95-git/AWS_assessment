variable "primary_region" {
  description = "Primary AWS region"
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary AWS region"
  default     = "eu-west-1"
}

variable "email" {
  description = "Email used for Cognito test user"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository URL"
  type        = string
}