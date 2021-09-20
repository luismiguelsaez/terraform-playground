locals {
  account = read_terragrunt_config(find_in_parent_folders("account.hcl",find_in_parent_folders("defaults.hcl")))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl",find_in_parent_folders("defaults.hcl")))
  project  = read_terragrunt_config(find_in_parent_folders("project.hcl",find_in_parent_folders("defaults.hcl")))

  account_name = local.account.locals.account_name
  account_id = local.account.locals.account_id
  region_name = local.region.locals.region_name
  project_name = local.project.locals.project_name
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  region  = "${local.region_name}"
  profile = "lokalise-admin-${local.account_name}"
}
EOF
}
