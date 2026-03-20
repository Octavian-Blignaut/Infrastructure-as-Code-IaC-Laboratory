##############################################################################
# environments/dev/outputs.tf
##############################################################################

output "vpc_id" {
  description = "ID of the dev VPC."
  value       = module.networking.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.compute.alb_dns_name
}

output "db_endpoint" {
  description = "RDS connection endpoint (host:port)."
  value       = module.database.db_endpoint
}

output "assets_bucket_id" {
  description = "Name of the assets S3 bucket."
  value       = module.storage_assets.bucket_id
}

output "iam_lab_user_arn" {
  description = "ARN of IAM lab user (null when IAM lab is disabled)."
  value       = module.iam_lab.user_arn
}

output "iam_lab_policy_arn" {
  description = "ARN of IAM lab S3 read-only policy (null when IAM lab is disabled)."
  value       = module.iam_lab.policy_arn
}

output "iam_lab_ec2_role_arn" {
  description = "ARN of IAM lab EC2-assumable role (null when IAM lab is disabled)."
  value       = module.iam_lab.ec2_role_arn
}

output "iam_lab_ec2_instance_profile_name" {
  description = "Name of IAM lab EC2 instance profile (null when IAM lab is disabled)."
  value       = module.iam_lab.ec2_instance_profile_name
}
