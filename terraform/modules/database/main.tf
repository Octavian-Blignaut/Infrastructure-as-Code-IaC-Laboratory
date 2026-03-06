##############################################################################
# modules/database/main.tf
#
# Creates:
#   - DB subnet group across private subnets
#   - PostgreSQL parameter group (tuned for the chosen instance class)
#   - RDS PostgreSQL instance with encryption, automated backups, Multi-AZ,
#     and deletion protection
##############################################################################

locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )
}

# ──────────────────────────────────────────────────────────────────────────────
# DB Subnet Group
# ──────────────────────────────────────────────────────────────────────────────

resource "aws_db_subnet_group" "this" {
  name        = "${local.name_prefix}-db-subnet-group"
  description = "Subnet group for ${local.name_prefix} RDS instance"
  subnet_ids  = var.private_subnet_ids

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-db-subnet-group" })
}

# ──────────────────────────────────────────────────────────────────────────────
# Parameter Group
# ──────────────────────────────────────────────────────────────────────────────

resource "aws_db_parameter_group" "this" {
  name        = "${local.name_prefix}-pg15"
  family      = "postgres15"
  description = "Custom parameter group for ${local.name_prefix}"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000" # log queries taking more than 1 s
  }

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pg15" })

  lifecycle {
    create_before_destroy = true
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# RDS Instance
# ──────────────────────────────────────────────────────────────────────────────

resource "aws_db_instance" "this" {
  identifier = "${local.name_prefix}-postgres"

  # Engine
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage
  storage_type          = "gp3"
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = true

  # Credentials
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Networking
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false

  # High Availability
  multi_az = var.multi_az

  # Parameter group
  parameter_group_name = aws_db_parameter_group.this.name

  # Backup & maintenance
  backup_retention_period    = var.backup_retention_period
  backup_window              = "02:00-03:00"
  maintenance_window         = "mon:04:00-mon:05:00"
  copy_tags_to_snapshot      = true
  auto_minor_version_upgrade = true

  # Deletion protection
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name_prefix}-final-snapshot"

  # Performance Insights (enabled by default for production visibility)
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-postgres" })
}
