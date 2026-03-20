output "user_arn" {
  description = "ARN of IAM lab user (null when disabled)."
  value       = var.enable_iam_lab ? aws_iam_user.lab_user[0].arn : null
}

output "policy_arn" {
  description = "ARN of IAM lab S3 read policy (null when disabled)."
  value       = var.enable_iam_lab ? aws_iam_policy.s3_read[0].arn : null
}

output "ec2_role_arn" {
  description = "ARN of IAM lab EC2 role (null when disabled)."
  value       = var.enable_iam_lab ? aws_iam_role.ec2_role[0].arn : null
}

output "ec2_instance_profile_name" {
  description = "Name of IAM lab EC2 instance profile (null when disabled)."
  value       = var.enable_iam_lab ? aws_iam_instance_profile.ec2_profile[0].name : null
}
