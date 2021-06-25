variable "zone_id" {
  description = "The Route53 zone ID where we're going to create the latency-based records"
}

variable "environment" {
  type    = string
  default = "Testing"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "cluster_name" {
  type    = string
  default = "eks-test"
}