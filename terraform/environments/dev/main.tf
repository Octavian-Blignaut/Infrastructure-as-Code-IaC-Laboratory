##############################################################################
# environments/dev/main.tf
#
# Wires together the four reusable modules to create a complete dev
# environment:  VPC → compute (ASG + ALB) → RDS → S3
##############################################################################

locals {
  environment        = "dev"
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
}

# ──────────────────────────────────────────────────────────────────────────────
# Networking
# ──────────────────────────────────────────────────────────────────────────────

module "networking" {
  source = "../../modules/networking"

  project     = var.project
  environment = local.environment

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  availability_zones   = local.availability_zones

  # Use a single NAT GW in dev to keep costs down.
  enable_nat_gateway = true
  single_nat_gateway = true
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
  instance_type = "t3.micro"

  # Minimal footprint for dev.
  asg_min_size         = 1
  asg_max_size         = 2
  asg_desired_capacity = 1
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

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 50

  # Dev settings: no HA, short backup retention, allow easy teardown.
  multi_az                = false
  backup_retention_period = 1
  deletion_protection     = false
  skip_final_snapshot     = true
}

# ──────────────────────────────────────────────────────────────────────────────
# Storage
# ──────────────────────────────────────────────────────────────────────────────

module "storage_assets" {
  source = "../../modules/storage"

  project       = var.project
  environment   = local.environment
  bucket_suffix = "assets"

  # Allow force-destroy in dev so the environment can be torn down cleanly.
  force_destroy = true

  # Shorter lifecycle in dev.
  lifecycle_transition_ia_days      = 30
  lifecycle_transition_glacier_days = 90
  lifecycle_expiration_days         = 90
}

# ──────────────────────────────────────────────────────────────────────────────
# IAM Lab (opt-in)
#
# Split into dedicated module files:
# - iam/policies.tf
# - iam/roles.tf
# - iam/bindings.tf
# ──────────────────────────────────────────────────────────────────────────────

module "iam_lab" {
  source = "./iam"

  project           = var.project
  environment       = local.environment
  enable_iam_lab    = var.enable_iam_lab
  iam_lab_user_name = var.iam_lab_user_name
  assets_bucket_arn = module.storage_assets.bucket_arn
}
