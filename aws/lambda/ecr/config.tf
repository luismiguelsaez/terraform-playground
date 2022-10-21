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
}

data "aws_caller_identity" "current" {}
