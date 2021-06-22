module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.0.3"

  cluster_name    = format("%s-%s", var.environment, var.cluster_name)
  cluster_version = var.k8s_version

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  node_groups = {
    web = {
      desired_capacity = 1
      max_capacity     = 3
      min_capacity     = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      k8s_labels = {
        Environment = var.environment
        Selector    = "web"
      }
    },
    db = {
      desired_capacity = 1
      max_capacity     = 3
      min_capacity     = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      k8s_labels = {
        Environment = var.environment
        Selector    = "db"
      }
    }
  }
}
