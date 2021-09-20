terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc.git///?ref=v3.7.0"
}

include {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  name = include.locals.project_name
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Terraform = "true"
    Environment = include.locals.account_name
  }
}
