##############################################################################
# modules/storage/outputs.tf
##############################################################################

output "bucket_id" {
  description = "Name (ID) of the S3 bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket (e.g. for CloudFront origins)."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_versioning_status" {
  description = "Current versioning status of the bucket."
  value       = aws_s3_bucket_versioning.this.versioning_configuration[0].status
}
