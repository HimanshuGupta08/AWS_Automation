tags = {
  Example    = "elasti-cache-sample"
  Name       = "elasti-cache-sample"
  Repository = "https://github.com/terraform-aws-modules/terraform-aws-network-firewall"
  Environment = "Dev" 
  Role = "AWS_wafr"
  Owner = "himanshu.gupta@cloudeq.com"

  START_DATE = ""
  END_DATE = ""
  PROJECT_NAME = "https://cloudeq.atlassian.net/browse/ADWS-13"
  PROJECT_TITLE = "AWS DevSecOps WAFR Solutions"
  DEPARTMENT_NAME = "Azure DevOps"
  APPLICATION_NAME = "AWS Network Firewall"
  CLIENT_NAME = "CEQ_Internal"
  SOW_NUMBER = "CEQSOW24084OV"
}

region = "eu-west-1"

name = "eccluster"

vpc_cidr = "10.0.0.0/16"

elasticache_disabled_create = "false"

create_cluster = "true"

apply_immediately = "true"

create_replication_group = "false"

memcached_engine = "memcached"

redis_engine = "redis"

memcached_engine_version = "1.6.17"

redis_engine_version = "7.1"

replication_group_engine_version = "7.1"

az_mode = "cross-az"

node_type = "cache.t4g.small"

num_cache_nodes = "2"

maintenance_window = "sun:05:00-sun:09:00"

create_parameter_group = "true"

memcached_parameter_group_family = "memcached1.6"

redis_parameter_group_family = "redis7"

replication_group_parameter_group_family = "redis7"

transit_encryption_enabled = "true"

auth_token = "PickSomethingMoreSecure123!"

