##############################################################################
# environments/prod/outputs.tf
##############################################################################

output "vpc_id" {
  description = "ID of the prod VPC."
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

output "logs_bucket_id" {
  description = "Name of the logs S3 bucket."
  value       = module.storage_logs.bucket_id
}
