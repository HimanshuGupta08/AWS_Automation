output "memcached_cluster_arn" {
  description = "The ARN of the ElastiCache Cluster"
  value       = module.memcached_elasticache.cluster_id
}

output "redis_cluster_arn" {
  description = "The ARN of the ElastiCache Cluster"
  value       = module.redis_elasticache.cluster_id
}

output "memcached_cluster_engine" {
  description = "The ARN of the ElastiCache Cluster"
  value       = module.memcached_elasticache.engine_version
}

output "redis_cluster_engine" {
  description = "The ARN of the ElastiCache Cluster"
  value       = module.memcached_elasticache.engine_version
}

output "memcached_parameter_group_name" {
  description = "The ARN of the ElastiCache Cluster"
  value       = module.memcached_elasticache.parameter_group_name
}

output "redis_parameter_group_name" {
  description = "The ARN of the ElastiCache Cluster"
  value       = module.memcached_elasticache.parameter_group_name
}

output "replication_group_id" {
    description = "The Replication group id of the ElastiCache Cluster"
    value = module.elasticache.replication_group_id
}

output "vpc_name" {
    description = "The Name of the VPC"
    value = module.vpc.name
}
