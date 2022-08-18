resource "vault_auth_backend" "this" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "this" {
  backend                 = vault_auth_backend.this.path
  kubernetes_host         = var.kubernetes_host
  kubernetes_ca_cert      = var.kubernetes_ca_cert
  token_reviewer_jwt      = data.kubernetes_secret_v1.this.data.token
  disable_iss_validation  = true
  disable_local_ca_jwt    = false
}

data "kubernetes_service_account_v1" "this" {
  metadata {
    name      = var.sa_name
    namespace = var.sa_namespace
  }
}

data "kubernetes_secret_v1" "this" {
  metadata {
    name = "${data.kubernetes_service_account_v1.this.default_secret_name}"
    namespace = var.sa_namespace
  }
}

resource "vault_policy" "this" {
  name = var.vault_policy_name

  policy = var.vault_policy
}

resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = vault_auth_backend.this.path
  role_name                        = var.vault_role_name
  bound_service_account_names      = [var.sa_name]
  bound_service_account_namespaces = [var.sa_namespace]
  token_ttl                        = 3600
  token_policies                   = [var.vault_policy_name]
  token_type                       = "service"
}