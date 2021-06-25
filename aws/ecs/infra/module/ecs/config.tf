terraform {
  required_version = "=1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.46.0"
    }
  }
}

# Needed to specify current region in logGroup configuration
data "aws_region" "current" {}