provider "aws" {
  region = var.region

  # Tags added automatically to every resource we create
  default_tags {
    tags = {
      Project   = "mini-devops-lab"
      ManagedBy = "terraform"
    }
  }
}
