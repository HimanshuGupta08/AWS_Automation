variable "region" {
  description = "AWS region"
  type        = string
}

variable "name" {
  description = "Name of the cluster"
  type        = string
}

variable "create_cluster" {
  description = "Create an ElastiCache cluster"
  type        = bool
}

variable "create_replication_group" {
  description = "Create an ElastiCache replication group"
  type        = bool
}

variable "memcached_engine" {
  description = "AWS memcached engine"
  type        = string
}

variable "redis_engine" {
  description = "AWS redis engine"
  type        = string
}

variable "memcached_engine_version" {
  description = "AWS memcached engine version"
  type        = string
}

variable "redis_engine_version" {
  description = "AWS redis engine version"
  type        = string
}

variable "replication_group_engine_version" {
  description = "AWS replication group engine version"
  type        = string
}

variable "az_mode" {
  description = "AWS availability zone mode"
  type        = string
}

variable "node_type" {
  description = "AWS node type"
  type        = string
}

variable "num_cache_nodes" {
  description = "AWS number of cache nodes"
  type        = string
}

variable "apply_immediately" {
  description = "Apply the changes immediately"
  type        = bool
}

variable "maintenance_window" {
  description = "AWS maintenance window"
  type        = string
}

variable "create_parameter_group" {
  description = "Create an ElastiCache parameter group"
  type        = bool
}

variable "memcached_parameter_group_family" {
  description = "AWS memcached parameter group family"
  type        = string
}

variable "redis_parameter_group_family" {
  description = "AWS redis parameter group family"
}

variable "replication_group_parameter_group_family" {
  description = "AWS replication group parameter group family"
  type        = string
}

variable "transit_encryption_enabled" {
  description = "AWS transit encryption enabled"
  type        = bool
}

variable "auth_token" {
  description = "AWS auth token"
  type        = string
}

variable "elasticache_disabled_create" {
  description = "Disable creation of an ElastiCache cluster"
  type        = bool
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the ElastiCache cluster"
  type        = map 
}