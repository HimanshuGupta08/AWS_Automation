variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the file system"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "region" {
  description = "The AWS region in which to create the file system"
  type        = string
  # default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC in which to create the file system"
  type        = string
  # default     = "10.99.0.0/18"
}

variable "performance_mode" {
  description = "The file system performance mode. Can be either `generalPurpose` or `maxIO`. Default is `generalPurpose`"
  type        = string
  default     = null
}

variable "encrypted" {
  description = "If `true`, the disk will be encrypted"
  type        = bool
  default     = true
}

variable "provisioned_throughput_in_mibps" {
  description = "The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable with `throughput_mode` set to `provisioned`"
  type        = number
  default     = null
}

variable "throughput_mode" {
  description = "Throughput mode for the file system. Defaults to `bursting`. Valid values: `bursting`, `elastic`, and `provisioned`. When using `provisioned`, also set `provisioned_throughput_in_mibps`"
  type        = string
  default     = null
}

variable "lifecycle_policy" {
  description = "A file system [lifecycle policy](https://docs.aws.amazon.com/efs/latest/ug/API_LifecyclePolicy.html) object"
  type        = any
  default     = {}
}

variable "attach_policy" {
  description = "Determines whether a policy is attached to the file system"
  type        = bool
  default     = true
}

variable "bypass_policy_lockout_safety_check" {
  description = "A flag to indicate whether to bypass the `aws_efs_file_system_policy` lockout safety check. Defaults to `false`"
  type        = bool
  default     = null
}

variable "enable_backup_policy" {
  description = "Determines whether a backup policy is `ENABLED` or `DISABLED`"
  type        = bool
  default     = true
}

variable "create_replication_configuration" {
  description = "Determines whether a replication configuration is created"
  type        = bool
  default     = false
}

variable "policy" { 
  description = "A file system [policy](https://docs.aws.amazon.com/efs/latest/ug/API_FileSystemPolicy.html) object"
  type        = any
  default     = {}  
}