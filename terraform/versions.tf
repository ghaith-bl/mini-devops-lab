terraform {
  # Minimum Terraform CLI version
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Stay on major version 6, allow minor/patch updates
      version = "~> 6.0"
    }
  }
}
