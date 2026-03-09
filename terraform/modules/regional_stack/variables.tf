variable "region_provider" {
  description = "AWS provider for this region"
  type        = any
}

variable "email" {
  description = "Email used in SNS payloads"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo URL for payload"
  type        = string
}