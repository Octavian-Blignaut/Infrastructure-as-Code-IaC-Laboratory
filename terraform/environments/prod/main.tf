##############################################################################
# environments/prod/main.tf
#
# Production environment – high availability, deletion protection, full
# backup retention.
##############################################################################

locals {
  environment        = "prod"
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
}

# ──────────────────────────────────────────────────────────────────────────────
# Networking
# ──────────────────────────────────────────────────────────────────────────────

module "networking" {
  source = "../../modules/networking"

  project     = var.project
  environment = local.environment

  vpc_cidr             = "10.1.0.0/16"
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  private_subnet_cidrs = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  availability_zones   = local.availability_zones

  # One NAT GW per AZ for full redundancy in production.
  enable_nat_gateway = true
  single_nat_gateway = false
}

# ──────────────────────────────────────────────────────────────────────────────
# Compute
# ──────────────────────────────────────────────────────────────────────────────

module "compute" {
  source = "../../modules/compute"

  project     = var.project
  environment = local.environment

  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  alb_security_group_id = module.networking.alb_security_group_id
  app_security_group_id = module.networking.app_security_group_id

  ami_id        = var.ami_id
  instance_type = "t3.small"

  # Larger footprint for production.
  asg_min_size         = 2
  asg_max_size         = 8
  asg_desired_capacity = 3
}

# ──────────────────────────────────────────────────────────────────────────────
# Database
# ──────────────────────────────────────────────────────────────────────────────

module "database" {
  source = "../../modules/database"

  project     = var.project
  environment = local.environment

  vpc_id               = module.networking.vpc_id
  private_subnet_ids   = module.networking.private_subnet_ids
  db_security_group_id = module.networking.db_security_group_id

  db_password = var.db_password

  instance_class        = "db.t3.small"
  allocated_storage     = 50
  max_allocated_storage = 500

  # Production settings: HA, full backups, deletion protection.
  multi_az                = true
  backup_retention_period = 30
  deletion_protection     = true
  skip_final_snapshot     = false
}

# ──────────────────────────────────────────────────────────────────────────────
# Storage
# ──────────────────────────────────────────────────────────────────────────────

module "storage_assets" {
  source = "../../modules/storage"

  project       = var.project
  environment   = local.environment
  bucket_suffix = "assets"

  force_destroy = false

  # Standard lifecycle for production.
  lifecycle_transition_ia_days      = 30
  lifecycle_transition_glacier_days = 90
  lifecycle_expiration_days         = 365
}

module "storage_logs" {
  source = "../../modules/storage"

  project       = var.project
  environment   = local.environment
  bucket_suffix = "logs"

  force_destroy = false

  # Logs transition faster; keep non-current versions for 90 days.
  lifecycle_transition_ia_days      = 14
  lifecycle_transition_glacier_days = 60
  lifecycle_expiration_days         = 90
}
