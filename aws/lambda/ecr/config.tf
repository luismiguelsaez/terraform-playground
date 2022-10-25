terraform {
  required_version = "~>1"
  required_providers {
    aws = {
      version = "~>4"
      source = "hashicorp/aws"
    }
  }

  
}

provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Environment = var.environment
    }
  }
}

data "aws_caller_identity" "current" {}
