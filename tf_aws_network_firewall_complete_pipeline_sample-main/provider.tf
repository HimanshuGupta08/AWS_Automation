provider "aws" {
  region = var.region
}

# backend configuration

 terraform {
   backend "s3" {
    
   }
 }
