output "oidc_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}