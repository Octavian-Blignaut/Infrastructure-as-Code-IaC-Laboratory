##############################################################################
# modules/database/outputs.tf
##############################################################################

output "db_instance_id" {
  description = "Identifier of the RDS instance."
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "ARN of the RDS instance."
  value       = aws_db_instance.this.arn
}

output "db_endpoint" {
  description = "Connection endpoint (host:port) of the RDS instance."
  value       = aws_db_instance.this.endpoint
}

output "db_host" {
  description = "Hostname of the RDS instance."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Port the RDS instance listens on."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Name of the initial database."
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "Master username for the database."
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "db_subnet_group_id" {
  description = "ID of the DB subnet group."
  value       = aws_db_subnet_group.this.id
}
