terraform {
  required_version = "=0.15.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.44.0"
    }
  }
  backend "s3" {
    bucket   = "cmpdevel-terraform-state"
    key      = "eks-test/tfstate"
    region   = "us-east-1"
    role_arn = "arn:aws:iam::393788435358:role/DelegatedAdministrator"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = var.environment
      Terraform   = true
      Author      = "Luismi"
    }
  }
  assume_role {
    role_arn = "arn:aws:iam::393788435358:role/DelegatedAdministrator"
  }
}

