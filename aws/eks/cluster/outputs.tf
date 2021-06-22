#output "oidc_url" {
#  value = module.eks.cluster_oidc_issuer_url
#}
#
#output "cluster_endpoint" {
#  value = module.eks.cluster_endpoint
#}

output "vpc_name" {
  value = module.vpc.name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_default_sg_id" {
  value = module.vpc.default_security_group_id
}

output "vpc_private_subnets" {
  value = module.vpc.private_subnets
}

output "vpc_public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_nat_public_ips" {
  value = module.vpc.nat_public_ips
}