# We're going to use the same ECS module for each region, specifiyng the custom provider

module "vpc_ireland" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.1.0"

  providers = {
    aws = aws.ireland
  }

  name = var.environment
  cidr = var.vpc_cidr

  # Creating public subnets for the LB and private ones for the ECS nodes
  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  # Attaching NGW to private subnets ( route ) to enable instances to reach the internet
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
}

module "ecs_ireland" {
  source = "../module/ecs"

  providers = {
    aws = aws.ireland
  }

  # Variables from VPC module
  vpc_id          = module.vpc_ireland.vpc_id
  private_subnets = module.vpc_ireland.private_subnets
  public_subnets  = module.vpc_ireland.public_subnets

  service_name          = "web"
  service_desired_count = 2

  instance_type    = "t3.large"
  cluster_name     = "luismiguelsaez-test"
  cluster_max_size = 4
  cluster_min_size = 1
}
