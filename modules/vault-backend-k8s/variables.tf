variable "kubernetes_host" {
  type    = string
  default = ""
}

variable "kubernetes_ca_cert" {
  type     = string
  default = ""
}

variable "token_reviewer_jwt" {
  type    = string
  default = ""
}

variable "sa_name" {
  type    = string
  default = ""
}

variable "sa_namespace" {
  type    = string
  default = ""
}

variable "vault_policy" {
  type    = string
  default = ""
}

variable "vault_policy_name" {
  type    = string
  default = ""
}

variable "vault_role_name" {
  type    = string
  default = ""
}
