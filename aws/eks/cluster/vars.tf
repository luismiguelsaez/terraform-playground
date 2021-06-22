variable "environment" {
  type    = string
  default = "Testing"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "azs" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "cluster_name" {
  type    = string
  default = "eks-test"
}

variable "k8s_version" {
  type    = string
  default = "1.20"
}