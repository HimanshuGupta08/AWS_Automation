locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

################################################################################
# EFS Module
################################################################################

module "efs" {
  source = "git::https://github.com/cloudeq-EMU-ORG/ceq_tf_module_aws_efs_master.git"

  # File system
  name           = var.name
  creation_token = "${var.name}-efs-token"
  encrypted      = var.encrypted
  kms_key_arn    = module.kms.key_arn

  performance_mode = var.performance_mode
  # NB! PROVISIONED TROUGHPUT MODE WITH 256 MIBPS IS EXPENSIVE ~$1500/month
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps

  lifecycle_policy = var.lifecycle_policy

  # File system policy
  attach_policy                      = var.attach_policy
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  
  policy_statements = [
    {
      sid     = "Example"
      actions = ["elasticfilesystem:ClientMount"]
      principals = [
        {
          type        = "AWS"
          identifiers = [data.aws_caller_identity.current.arn]
        }
      ]
    }
  ]

  # Mount targets / security group
  mount_targets              = { for k, v in zipmap(local.azs, module.vpc.private_subnets) : k => { subnet_id = v } }
  security_group_description = "EFS security group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  # Access point(s)
  access_points = {
    posix_example = {
      name = "posix-example"
      posix_user = {
        gid            = 1001
        uid            = 1001
        secondary_gids = [1002]
      }

      tags = var.tags
    }
    root_example = {
      root_directory = {
        path = "/example"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    }
  }

  # Backup policy
  enable_backup_policy = var.enable_backup_policy

  # Replication configuration
  create_replication_configuration = var.create_replication_configuration
  replication_configuration_destination = [
    {
      availability_zone_name = "eu-west-1a"
      region      = "eu-west-1"
      kms_key_id    = "arn:aws:kms:eu-west-1:533267235239:key/c23212b3-acf3-4bdd-a40a-e270bc4d7d2a"
      destination = "eu-west-2"
    }
  ]

  tags = var.tags
}

module "efs_default" {
  source = "git::https://github.com/cloudeq-EMU-ORG/ceq_tf_module_aws_efs_master.git"

  name = "${var.name}-efsdefault"
  kms_key_arn = module.kms.key_arn

  tags = var.tags
}

module "efs_disabled" {
  source = "git::https://github.com/cloudeq-EMU-ORG/ceq_tf_module_aws_efs_master.git"
  
  kms_key_arn = module.kms.key_arn

  create = false
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "git::https://github.com/cloudeq-EMU-ORG/ceq_tf_module_aws_network_firewall_vpc_module.git"

  name = "${var.name}-efsvpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 10)]

  enable_nat_gateway = false
  single_nat_gateway = true

  tags = var.tags
}

module "kms" {
  source  = "git::https://github.com/cloudeq-EMU-ORG/aws-war-kms-template.git"

  aliases               = ["efs/${var.name}"]
  description           = "EFS customer managed key"
  enable_default_policy = true

  # For example use only
  deletion_window_in_days = 7

  tags = var.tags
}