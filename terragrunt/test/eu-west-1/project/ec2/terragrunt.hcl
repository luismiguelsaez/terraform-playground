terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-ec2-instance.git///?ref=v3.1.0"
}

include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs_allowed_terraform_commands = ["init","validate"]
  mock_outputs = {
    vpc_id = "mocked-vpc-id"
    public_subnet_arns = ["arn:fake-subnet-1","arn:fake-subnet-2"]
    default_security_group_id = "sg-00000000"
  }
}

inputs = {
  name = include.locals.project_name
  subnet_id = dependency.vpc.outputs.public_subnet_arns
  vpc_security_group_ids = [dependency.vpc.outputs.default_security_group_id]

  tags = {
    Terraform = "true"
    Environment = include.locals.account_name
  }
}
