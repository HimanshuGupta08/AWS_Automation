tags = {
  Example    = "efs-sample"
  Name       = "efs-sample"
  Repository = "https://github.com/terraform-aws-modules/terraform-aws-efs.git"
  Environment = "Dev" 
  Role = "AWS_wafr"
  Owner = "himanshu.gupta@cloudeq.com"

  START_DATE = ""
  END_DATE = ""
  PROJECT_NAME = "https://cloudeq.atlassian.net/browse/ADWS-38"
  PROJECT_TITLE = "AWS DevSecOps WAFR Solutions"
  DEPARTMENT_NAME = "Azure DevOps"
  APPLICATION_NAME = "AWS EFS"
  CLIENT_NAME = "CEQ_Internal"
  SOW_NUMBER = "CEQSOW24084OV"
}

region = "eu-west-1"

name = "efs-sample"

vpc_cidr = "10.0.0.0/16"

lifecycle_policy = {
  transition_to_ia                    = "AFTER_30_DAYS"
  transition_to_primary_storage_class = "AFTER_1_ACCESS"
}

create = "true"

performance_mode = "maxIO" 

provisioned_throughput_in_mibps = 256

encrypted = "true"

throughput_mode = "provisioned"

attach_policy = "true"

bypass_policy_lockout_safety_check = "false"

enable_backup_policy = "true"

create_replication_configuration = "true"

policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::533267235239:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow access for Key Administrators",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::533267235239:user/aws_Wafr_user"
      },
      "Action": [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::533267235239:user/aws_Wafr_user"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::533267235239:user/aws_Wafr_user"
      },
      "Action": [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ],
      "Resource": "*"
    }
  ]
}
EOF
