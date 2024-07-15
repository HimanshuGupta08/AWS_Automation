# provider configuration
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.47"
    }
  }
}

#backend configuration
 terraform {
   backend "s3" {
    region = "eu-west-1"
   }
 }