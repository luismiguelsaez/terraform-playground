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
  default = ["us-east-1a", "us-east-1b"]
}

variable "cluster_name" {
  type    = string
  default = "eks-test"
}

variable "k8s_version" {
  type    = string
  default = "1.20"
}