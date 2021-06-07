module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.0.3"

  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version

  cluster_create_security_group = true
  cluster_endpoint_private_access = true
  cluster_create_endpoint_private_access_sg_rule = true
  cluster_endpoint_private_access_cidrs = ["37.120.141.144/32"]
  #cluster_endpoint_private_access_sg = 
  #cluster_service_ipv4_cidr = "192.168.0.0/24"

  vpc_id  = aws_vpc.main.id
  subnets = aws_subnet.public.*.id
}
