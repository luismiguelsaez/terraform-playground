terraform {
  required_version = "=1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.46.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.3.2"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      Environment = "Lambda-EFS"
      Terraform   = true
      Author      = "Luismi"
    }
  }
}