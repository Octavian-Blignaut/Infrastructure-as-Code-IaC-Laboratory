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
# Safe experimentation surface for IAM in dev:
# - Creates a test IAM user (no access keys generated).
# - Grants least-privilege read access to the dev assets S3 bucket.
# - Creates an EC2-assumable role with the same S3 read policy.
#
# Toggle with var.enable_iam_lab.
# ──────────────────────────────────────────────────────────────────────────────

data "aws_iam_policy_document" "iam_lab_s3_read" {
  statement {
    sid     = "AllowListBucket"
    effect  = "Allow"
    actions = ["s3:ListBucket"]

    resources = [
      module.storage_assets.bucket_arn
    ]
  }

  statement {
    sid     = "AllowGetObjects"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    resources = [
      "${module.storage_assets.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "iam_lab_s3_read" {
  count       = var.enable_iam_lab ? 1 : 0
  name        = "${var.project}-${local.environment}-iam-lab-s3-read"
  description = "IAM lab policy: read-only access to dev assets bucket"
  policy      = data.aws_iam_policy_document.iam_lab_s3_read.json
}

resource "aws_iam_user" "iam_lab_user" {
  count = var.enable_iam_lab ? 1 : 0
  name  = var.iam_lab_user_name

  tags = {
    Purpose = "iam-lab"
  }
}

resource "aws_iam_user_policy_attachment" "iam_lab_user_s3_read" {
  count      = var.enable_iam_lab ? 1 : 0
  user       = aws_iam_user.iam_lab_user[0].name
  policy_arn = aws_iam_policy.iam_lab_s3_read[0].arn
}

data "aws_iam_policy_document" "iam_lab_ec2_assume_role" {
  statement {
    sid     = "AllowEC2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_lab_ec2_role" {
  count              = var.enable_iam_lab ? 1 : 0
  name               = "${var.project}-${local.environment}-iam-lab-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.iam_lab_ec2_assume_role.json

  tags = {
    Purpose = "iam-lab"
  }
}

resource "aws_iam_role_policy_attachment" "iam_lab_ec2_s3_read" {
  count      = var.enable_iam_lab ? 1 : 0
  role       = aws_iam_role.iam_lab_ec2_role[0].name
  policy_arn = aws_iam_policy.iam_lab_s3_read[0].arn
}

resource "aws_iam_instance_profile" "iam_lab_ec2_profile" {
  count = var.enable_iam_lab ? 1 : 0
  name  = "${var.project}-${local.environment}-iam-lab-ec2-profile"
  role  = aws_iam_role.iam_lab_ec2_role[0].name
}
