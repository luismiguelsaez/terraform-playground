terraform {
  required_version = "=1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.46.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.3.2"
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

