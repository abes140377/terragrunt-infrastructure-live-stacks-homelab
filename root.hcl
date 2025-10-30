# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform/OpenTofu that provides extra tools for working with multiple modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load account-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  environment_name = local.environment_vars.locals.environment_name

  proxmox_endpoint = "https://proxmox.home.sflab.io:8006/"

  s3_backend_region = "eu-central-1"
  s3_backend_endpoint  = "http://minio.home.sflab.io:9000"
  s3_backend_skip_credentials_validation = true
  s3_backend_force_path_style = true
  s3_backend_access_key = get_env("AWS_ACCESS_KEY_ID")
  s3_backend_secret_key = get_env("AWS_SECRET_ACCESS_KEY")
}

# Generate Proxmox provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "proxmox" {
  endpoint  = "${local.proxmox_endpoint}"
  insecure  = true

  ssh {
    agent = true
  }
}
EOF
}

# Generate the remote backend
remote_state {
  backend = "s3"

  config = {
    bucket                      = "${local.environment_name}-homelab-terragrunt-tfstates"

    key                         = "${path_relative_to_include()}/tofu.tfstate"
    region                      = local.s3_backend_region
    endpoint                    = local.s3_backend_endpoint
    skip_credentials_validation = local.s3_backend_skip_credentials_validation
    force_path_style            = local.s3_backend_force_path_style
    access_key                  = local.s3_backend_access_key
    secret_key                  = local.s3_backend_secret_key
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Configure what repositories to search when you run 'terragrunt catalog'
catalog {
  urls = [
    "https://github.com/abes140377/terragrunt-infrastructure-catalog-homelab.git",
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
# inputs = merge(
#   local.environment_vars.locals,
#   # local.region_vars.locals,
# )
