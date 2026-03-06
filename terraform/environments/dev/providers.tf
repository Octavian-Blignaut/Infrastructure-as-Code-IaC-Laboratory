##############################################################################
# environments/dev/providers.tf
#
# Provider and Terraform version constraints for the dev environment.
##############################################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state – swap the placeholder values for your real S3 bucket and
  # DynamoDB lock table before running terraform init.
  backend "s3" {
    bucket         = "REPLACE_ME_tf-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "REPLACE_ME_tf-lock-table"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project
      Environment = "dev"
      ManagedBy   = "terraform"
      Repository  = "Infrastructure-as-Code-IaC-Laboratory"
    }
  }
}
