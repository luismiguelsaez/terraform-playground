data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

### Needed when manage_aws_auth is enabled, to be able to connect to API server
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.0.3"

  cluster_name    = format("%s-%s", var.environment, var.cluster_name)
  cluster_version = var.k8s_version

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  manage_aws_auth = false

  ### Defaults https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v17.0.3/local.tf
  ### local.workers_group_defaults_defaults
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
