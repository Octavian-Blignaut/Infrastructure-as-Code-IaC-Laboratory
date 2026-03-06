##############################################################################
# modules/networking/outputs.tf
##############################################################################

output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the created VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets (one per AZ)."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (one per AZ)."
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways (empty when NAT is disabled)."
  value       = aws_nat_gateway.this[*].id
}

output "alb_security_group_id" {
  description = "Security-group ID for the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security-group ID for the application tier (EC2 instances)."
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "Security-group ID for the database tier (RDS)."
  value       = aws_security_group.db.id
}
