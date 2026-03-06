##############################################################################
# modules/compute/outputs.tf
##############################################################################

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.app.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.app.arn
}

output "alb_zone_id" {
  description = "Route 53 hosted zone ID of the ALB (for alias records)."
  value       = aws_lb.app.zone_id
}

output "target_group_arn" {
  description = "ARN of the ALB target group."
  value       = aws_lb_target_group.app.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group."
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "ID of the EC2 launch template."
  value       = aws_launch_template.app.id
}

output "launch_template_latest_version" {
  description = "Latest version number of the EC2 launch template."
  value       = aws_launch_template.app.latest_version
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to EC2 instances."
  value       = aws_iam_role.app.arn
}
