data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  azs     = slice(data.aws_availability_zones.available.names, 0, 3)
}

################################################################################
# network firewall Module
################################################################################

module "network_firewall" {
  source = "git::https://github.com/cloudeq-EMU-ORG/ceq_tf_template_aws_network-firewall.git?ref=817eb36"
  
  # Firewall
  name = var.name_prefix
  description = "Example network firewall"

  # Only for example
  delete_protection = false
  firewall_policy_change_protection = false
  subnet_change_protection = false

  vpc_id = module.vpc.vpc_id
  subnet_mapping = { for i in range(0, var.num_azs) :
    "subnet-${i}" => {
      subnet_id = element(module.vpc.public_subnets, i)
      ip_address_type = "IPV4"
    }
  }

  # Logging configuration
  create_logging_configuration = true
  logging_configuration_destination_config = [
    {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.logs.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type = "ALERT"
    },
    {
      log_destination = {
        bucketName = aws_s3_bucket.network_firewall_logs.id
        prefix = "${var.name_prefix}-log-destination"
      }
      log_destination_type = "S3"
      log_type = "FLOW"
    }
  ]

  # Policy
  policy_name = "${var.name_prefix}-policy"
  policy_description = "Example network firewall policy"

  policy_stateful_rule_group_reference = {
    one = { resource_arn = module.network_firewall_rule_group_stateful.arn }
  }

  policy_stateless_default_actions = ["aws:pass"]
  policy_stateless_fragment_default_actions = ["aws:drop"]
  policy_stateless_rule_group_reference = {
    one = {
      priority     = 1
      resource_arn = module.network_firewall_rule_group_stateless.arn
    }
  }

  tags = var.tags
}

module "network_firewall_disabled" {
  source = "git::https://github.com/cloudeq-EMU-ORG/ceq_tf_template_aws_network-firewall.git?ref=817eb36"
  create = false
}

################################################################################
# Network Firewall Rule Group
################################################################################

module "network_firewall_rule_group_stateful" {
  source = "git::https://github.com/cloudeq-EMU-ORG/ceq_tf_template_aws_network-firewall.git//modules/rule-group?ref=817eb36"

  name = "${var.name_prefix}-stateful"
  description = "Stateful Inspection for denying access to a domain"
  type = "STATEFUL"
  capacity = 100

  rule_group = {
    rules_source = {
      rules_source_list = {
        generated_rules_type = "DENYLIST"
        target_types = ["HTTP_HOST"]
        targets = ["test.example.com"]
      }
    }
  }

  # Resource Policy
  create_resource_policy = true
  attach_resource_policy = true
  resource_policy_principals = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]

  tags = var.tags
}

module "network_firewall_rule_group_stateless" {
  source = "git::https://github.com/cloudeq-EMU-ORG/ceq_tf_template_aws_network-firewall.git//modules/rule-group?ref=817eb36"

  name = "${var.name_prefix}-stateless"
  description = "Stateless Inspection with a Custom Action"
  type = "STATELESS"
  capacity = 100

  rule_group = {
    rules_source = {
      stateless_rules_and_custom_actions = {
        custom_action = [{
          action_definition = {
            publish_metric_action = {
              dimension = [{
                value = "2"
              }]
            }
          }
          action_name = "ExampleMetricsAction"
        }]
        stateless_rule = [{
          priority = 1
          rule_definition = {
            actions = ["aws:pass", "ExampleMetricsAction"]
            match_attributes = {
              source = [{
                address_definition = "1.2.3.4/32"
              }]
              source_port = [{
                from_port = 443
                to_port = 443
              }]
              destination = [{
                address_definition = "124.1.1.5/32"
              }]
              destination_port = [{
                from_port = 443
                to_port = 443
              }]
              protocols = [6]
              tcp_flag = [{
                flags = ["SYN"]
                masks = ["SYN", "ACK"]
              }]
            }
          }
        }]
      }
    }
  }

  # Resource Policy
  create_resource_policy = true
  attach_resource_policy = true
  resource_policy_principals = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]

  tags = var.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source = "git::https://github.com/cloudeq-EMU-ORG/ceq_tf_module_aws_network_firewall_vpc_module.git?ref=ff8af86"
  enable_flow_log = true

  name = "${var.name_prefix}-firewall-vpc"
  cidr = var.vpc_cidr

  azs = slice(data.aws_availability_zones.available.names, 0, var.num_azs)
  public_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 10)]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "${var.name_prefix}-logs"
  retention_in_days = 365
  kms_key_id = var.kms_arn
  tags = var.tags
}

resource "aws_s3_bucket" "network_firewall_logs" {
  bucket = "firewall-log-bucket-himanshu"
  force_destroy = true

  acceleration_status = "Enabled"

  logging {
        target_bucket = "log-target-bucket-firewall"
        target_prefix = "server-access-logs/"
      }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = var.kms_arn
      }
      bucket_key_enabled = true
    }
  }

  versioning {
    enabled = true
  # mfa_delete = true
  }

  replication_configuration {
    role = aws_iam_role.replication.arn
    rules {
      id     = "foobar"
      prefix = "foo"
      status = "Enabled"

      destination {
        bucket        = "arn:aws:s3:::log-target-bucket-firewall"
        storage_class = "STANDARD"
      }
    }
  }

  lifecycle_rule {
    id = "cc-transition-access-log-data"
    enabled = true

    prefix = "log/"

    tags = var.tags

    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }

  object_lock_configuration {
    object_lock_enabled = "Enabled"
    rule {
      default_retention {
        mode = "GOVERNANCE"
        days = 90
      }
    }
  }

  tags = var.tags
}

resource "aws_sns_topic" "bucket_notifications" {
  name = "${aws_s3_bucket.network_firewall_logs.id}-notifications"

  kms_master_key_id = var.kms_arn

  tags = var.tags
}

resource "aws_sns_topic_policy" "bucket_notifications_policy" {
  arn = aws_sns_topic.bucket_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.bucket_notifications.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.network_firewall_logs.arn
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.network_firewall_logs.id
  topic {
    topic_arn     = aws_sns_topic.bucket_notifications.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "logs/"
  }
}

resource "aws_s3_bucket_public_access_block" "network_firewall_logs_block" {
  bucket = aws_s3_bucket.network_firewall_logs.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# Logging configuration automatically adds this policy if not present
resource "aws_s3_bucket_policy" "network_firewall_logs" {
  bucket = aws_s3_bucket.network_firewall_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:PutObject"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
          }
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Resource = "${aws_s3_bucket.network_firewall_logs.arn}/${var.name_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Sid = "AWSLogDeliveryWrite"
      },
      {
        Action = "s3:GetBucketAcl"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
          }
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Resource = aws_s3_bucket.network_firewall_logs.arn
        Sid = "AWSLogDeliveryAclCheck"
      },
      {
        Sid = "RequireKMSEncryption"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.network_firewall_logs.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      },
      {
          Sid       = "RequireSSL"
          Effect    = "Deny"
          Principal = "*"
          Action    = "s3:*"
          Resource  = "${aws_s3_bucket.network_firewall_logs.arn}"
          Condition = {
            Bool = {
              "aws:SecureTransport" = "false"
            }
          }
        }
    ]
  })
}

# Add the missing IAM role declaration
resource "aws_iam_role" "replication" {
  name = "himanshu-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "replication" {
  role = aws_iam_role.replication.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:GetReplicationConfiguration",
          "s3:ListMultipartUploadParts"
        ],
        Resource = [
          "arn:aws:s3:::firewall-log-bucket-himanshu",
          "arn:aws:s3:::firewall-log-bucket-himanshu/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:ObjectOwnerOverrideToBucketOwner"
        ],
        Resource = "arn:aws:s3:::log-target-bucket-firewall/*"
      }
    ]
  })
}
