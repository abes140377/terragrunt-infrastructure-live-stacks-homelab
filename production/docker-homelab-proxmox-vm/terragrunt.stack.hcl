locals {
  # Load environment variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  # Extract variables we need for easy access
  environment_name = local.environment_vars.locals.environment_name

  # Use environment_name in stack name
  name = "docker-homelab-proxmox-vm-${local.environment_name}"
}

unit "proxmox_pool" {
  // You'll typically want to pin this to a particular version of your catalog repo.
  // e.g.
  // source = "git::git@github.com:abes140377/terragrunt-infrastructure-catalog-homelab.git//units/proxmox-pool?ref=v0.1.0"
  source = "git::git@github.com:abes140377/terragrunt-infrastructure-catalog-homelab.git//units/proxmox-pool"

  path = "proxmox-pool"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    pool_id = "pool-${local.environment_name}"
  }
}



# unit "db" {
#   // You'll typically want to pin this to a particular version of your catalog repo.
#   // e.g.
#   // source = "git::git@github.com:abes140377/terragrunt-infrastructure-catalog-homelab.git//units/mysql?ref=v0.1.0"
#   source = "git::git@github.com:abes140377/terragrunt-infrastructure-catalog-homelab.git//units/mysql"

#   path = "db"

#   values = {
#     // This version here is used as the version passed down to the unit
#     // to use when fetching the OpenTofu/Terraform module.
#     version = "main"

#     name              = "${replace(local.name, "-", "")}db"
#     instance_class    = "db.t4g.micro"
#     allocated_storage = 20
#     storage_type      = "gp2"

#     # NOTE: This is only here to make it easier to spin up and tear down the stack.
#     # Do not use any of these settings in production.
#     master_username     = local.db_username
#     master_password     = local.db_password
#     skip_final_snapshot = true
#   }
# }

# // We create the security group outside of the ASG unit because
# // we want to handle the wiring of the ASG to the security group
# // to the DB before we start provisioning the service unit.
# unit "asg_sg" {
#   // You'll typically want to pin this to a particular version of your catalog repo.
#   // e.g.
#   // source = "git::git@github.com:abes140377/terragrunt-infrastructure-catalog-homelab.git//units/sg?ref=v0.1.0"
#   source = "git::git@github.com:abes140377/terragrunt-infrastructure-catalog-homelab.git//units/sg"

#   path = "sgs/asg"

#   values = {
#     // This version here is used as the version passed down to the unit
#     // to use when fetching the OpenTofu/Terraform module.
#     version = "main"

#     name = "${local.name}-asg-sg"
#   }
# }

# unit "sg_to_db_sg_rule" {
#   // You'll typically want to pin this to a particular version of your catalog repo.
#   // e.g.
#   // source = "git::git@github.com:abes140377/terragrunt-infrastructure-catalog-homelab.git//units/sg-to-db-sg-rule?ref=v0.1.0"
#   source = "git::git@github.com:abes140377/terragrunt-infrastructure-catalog-homelab.git//units/sg-to-db-sg-rule"

#   path = "rules/sg-to-db-sg-rule"

#   values = {
#     // This version here is used as the version passed down to the unit
#     // to use when fetching the OpenTofu/Terraform module.
#     version = "main"

#     // These paths are used for relative references
#     // to the service and db units as dependencies.
#     sg_path = "../../sgs/asg"
#     db_path = "../../db"
#   }
# }
