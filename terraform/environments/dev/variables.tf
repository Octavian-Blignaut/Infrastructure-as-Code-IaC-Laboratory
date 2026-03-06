##############################################################################
# environments/dev/variables.tf
##############################################################################

variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Short name used to prefix every resource."
  type        = string
  default     = "iaclab"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (Amazon Linux 2023 recommended)."
  type        = string
}

variable "db_password" {
  description = "Master password for the RDS instance. Use AWS Secrets Manager in production."
  type        = string
  sensitive   = true
}
