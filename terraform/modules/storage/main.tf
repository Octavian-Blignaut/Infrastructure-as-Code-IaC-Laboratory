##############################################################################
# modules/storage/main.tf
#
# Creates an S3 bucket with production-grade settings:
#   - Public access fully blocked
#   - Server-side encryption (AES-256 by default)
#   - Versioning
#   - Intelligent-Tiering / Glacier lifecycle rules
#   - Optional CORS configuration
#   - Bucket policy enforcing HTTPS-only access
##############################################################################

locals {
  name_prefix = "${var.project}-${var.environment}"
  bucket_name = "${local.name_prefix}-${var.bucket_suffix}"

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
# S3 Bucket
# ──────────────────────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = merge(local.common_tags, { Name = local.bucket_name })
}

# ── Public access block ───────────────────────────────────────────────────────

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── Versioning ────────────────────────────────────────────────────────────────

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# ── Server-side encryption ────────────────────────────────────────────────────

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# ── Lifecycle rules ───────────────────────────────────────────────────────────

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  # Current objects: transition to cheaper storage tiers over time.
  rule {
    id     = "transition-current-objects"
    status = "Enabled"

    filter {} # applies to all objects

    transition {
      days          = var.lifecycle_transition_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.lifecycle_transition_glacier_days
      storage_class = "GLACIER"
    }
  }

  # Non-current (versioned) objects: expire after a configurable period.
  rule {
    id     = "expire-noncurrent-versions"
    status = var.versioning_enabled && var.lifecycle_expiration_days > 0 ? "Enabled" : "Disabled"

    filter {} # applies to all objects

    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_expiration_days
    }
  }

  # Abort incomplete multipart uploads after 7 days.
  rule {
    id     = "abort-incomplete-multipart"
    status = "Enabled"

    filter {} # applies to all objects

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

# ── CORS (optional) ───────────────────────────────────────────────────────────

resource "aws_s3_bucket_cors_configuration" "this" {
  count = length(var.cors_allowed_origins) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# ── Bucket policy: enforce HTTPS-only access ──────────────────────────────────

data "aws_iam_policy_document" "https_only" {
  statement {
    sid     = "DenyHTTP"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "https_only" {
  bucket     = aws_s3_bucket.this.id
  policy     = data.aws_iam_policy_document.https_only.json
  depends_on = [aws_s3_bucket_public_access_block.this]
}
