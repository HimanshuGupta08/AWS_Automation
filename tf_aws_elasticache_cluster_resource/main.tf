provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  azs     = slice(data.aws_availability_zones.available.names, 0, 3)
}

################################################################################
# ElastiCache Module - memcached
################################################################################

module "memcached_elasticache" {
  source = "git::https://github.com/cloudeq-EMU-ORG/ceq_tf_module_aws_elasticache_modules_sample.git"

  cluster_id               = "${var.name}-memcached"
  create_cluster           = var.create_cluster
  create_replication_group = var.create_replication_group

  engine          = var.memcached_engine
  engine_version  = var.memcached_engine_version
  node_type       = var.node_type
  num_cache_nodes = var.num_cache_nodes
  az_mode         = var.az_mode

  maintenance_window = var.maintenance_window
  apply_immediately  = var.apply_immediately

  # Security Group
  vpc_id = module.vpc.vpc_id
  security_group_rules = {
    ingress_vpc = {
      description = "VPC traffic"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  # Subnet Group
  subnet_group_name        = "${var.name}-msubnetgroup"
  subnet_group_description = "${title(var.name)} m subnet group"
  subnet_ids               = module.vpc.private_subnets

  # Parameter Group
  create_parameter_group      = var.create_parameter_group
  parameter_group_name        = "${var.name}-mparametergroup"
  parameter_group_family      = var.memcached_parameter_group_family
  parameter_group_description = "${title(var.name)} m parameter group"
  parameters = [
    {
      name  = "idle_timeout"
      value = 60
    }
  ]

  tags = var.tags
}

################################################################################
# ElastiCache Module - redis
################################################################################

module "redis_elasticache" {
  source = "git::https://github.com/cloudeq-EMU-ORG/ceq_tf_module_aws_elasticache_modules_sample.git"

  cluster_id               = "${var.name}-redis"
  create_cluster           = var.create_cluster
  create_replication_group = var.create_replication_group

  engine_version = var.redis_engine_version
  node_type      = var.node_type

  maintenance_window = var.maintenance_window
  apply_immediately  = var.apply_immediately

  # Security Group
  vpc_id = module.vpc.vpc_id
  security_group_rules = {
    ingress_vpc = {
      description = "VPC traffic"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  # Subnet Group
  subnet_group_name        = "${var.name}-rsubnetgroup"
  subnet_group_description = "${title(var.name)} r subnet group"
  subnet_ids               = module.vpc.private_subnets

  # Parameter Group
  create_parameter_group      = true
  parameter_group_name        = "${var.name}-rparametergroup"
  parameter_group_family      = var.redis_parameter_group_family
  parameter_group_description = "${title(var.name)} r parameter group"
  parameters = [
    {
      name  = "latency-tracking"
      value = "yes"
    }
  ]

  tags = var.tags
}

module "elasticache_disabled" {
  source = "git::https://github.com/cloudeq-EMU-ORG/ceq_tf_module_aws_elasticache_modules_sample.git"

  create = var.elasticache_disabled_create
}

################################################################################
# ElastiCache Module - replication group
################################################################################

module "elasticache" {
  source = "git::https://github.com/cloudeq-EMU-ORG/ceq_tf_module_aws_elasticache_modules_sample.git"

  replication_group_id = "${var.name}-replication-group"

  engine_version = var.replication_group_engine_version
  node_type      = var.node_type

  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = var.auth_token
  maintenance_window         = var.maintenance_window
  apply_immediately          = var.apply_immediately

  # Security Group
  vpc_id = module.vpc.vpc_id
  security_group_rules = {
    ingress_vpc = {
      description = "VPC traffic"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  # Subnet Group
  subnet_group_name        = "${var.name}-replicationsubnetgroup"
  subnet_group_description = "${title(var.name)} subnet group"
  subnet_ids               = module.vpc.private_subnets

  # Parameter Group
  create_parameter_group      = var.create_parameter_group
  parameter_group_name        = "${var.name}-replicationparametergroup"
  parameter_group_family      = var.replication_group_parameter_group_family
  parameter_group_description = "${title(var.name)} parameter group"
  parameters = [
    {
      name  = "latency-tracking"
      value = "yes"
    }
  ]
  tags = var.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "git::https://github.com/cloudeq-EMU-ORG/ceq_tf_module_aws_network_firewall_vpc_module.git"

  name = "${var.name}-cluster_vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 10)]

  tags = var.tags
}