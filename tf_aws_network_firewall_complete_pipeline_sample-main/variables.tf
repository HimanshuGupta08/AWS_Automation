variable "region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "eu-west-1"
}

variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
  default     = "network-firewall-ex"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "num_azs" {
  description = "The number of availability zones to use."
  type        = number
  default     = 3
}

variable "tags" {
  description = "A map of tags to add to resources."
  type        = map(string)
  default     = {
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-network-firewall"
  }
}

variable "subnet_ids" {
  type    = list(string)
  # You can optionally set a default value if needed
  default = ["10.0.0.0/24"]
}

variable "security_group_ids" {
  type    = list(string)
  # You can optionally set a default value if needed
  default = ["10.0.0.0/32"]
}

variable "kms_arn" {
  description = "The ARN of the AWS Key Management Service (AWS KMS) key to use for encrypting the firewall state."
  type        = string
  default = "null"
}

variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "enable_flow_log" {
  description = "Whether or not to enable VPC Flow Logs"
  type        = bool
  default     = false
}
