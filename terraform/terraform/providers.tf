terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Primary region (also where Cognito will live)
provider "aws" {
  region = var.primary_region
}

# Second region for multi-region deployment
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}