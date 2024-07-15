region      = "eu-west-1"
name_prefix = "network-firewall"
vpc_cidr    = "10.0.0.0/16"
num_azs     = 3
tags = {
  Example    = "network-firewall-sample"
  Name       = "network-firewall-sample"
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

kms_arn = "arn:aws:kms:eu-west-1:533267235239:key/c23212b3-acf3-4bdd-a40a-e270bc4d7d2a"
