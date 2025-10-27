############################################
# Terraform & Provider (OAC requires aws >= 5.20)
############################################
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.20"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}