terraform {
  required_version = ">= 1.0.3"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.12.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
}
