output "secret_data_token" {
  sensitive = true
  value = data.kubernetes_secret_v1.this.data.token
}
