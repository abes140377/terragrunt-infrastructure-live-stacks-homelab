# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform/OpenTofu that provides extra tools for working with multiple modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Automatically load account-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  environment_name = local.environment_vars.locals.environment_name

  dns_server = "192.168.1.13"
  dns_port   = 53
  dns_key_name   = "home.sflab.io-key"
  dns_key_algorithm = "hmac-sha256"
}

# Generate DNS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
variable "dns_key_secret" {
  description = "TSIG key secret for DNS authentication"
  type        = string
  sensitive   = true
}

provider "dns" {
  update {
    server        = "${local.dns_server}"
    port          = ${local.dns_port}
    key_name      = "${local.dns_key_name}"
    key_algorithm = "${local.dns_key_algorithm}"
    key_secret    = var.dns_key_secret
  }
}
EOF
}
