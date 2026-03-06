##############################################################################
# modules/database/variables.tf
##############################################################################

variable "project" {
  description = "Short name used to prefix every resource."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev | staging | prod)."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to deploy into."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets for the RDS subnet group."
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security-group ID to attach to the RDS instance."
  type        = string
}

variable "db_name" {
  description = "Name of the initial database to create."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for the database."
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Master password for the database. Store in AWS Secrets Manager in production."
  type        = string
  sensitive   = true
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial allocated storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper limit for storage auto-scaling (0 = disabled)."
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Enable Multi-AZ for high availability."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Prevent accidental deletion of the RDS instance."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion (set true only for dev/test)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
