# Module: storage

Creates a secure, production-ready S3 bucket.

## Resources created

| Resource | Purpose |
|---|---|
| `aws_s3_bucket` | The S3 bucket |
| `aws_s3_bucket_public_access_block` | Blocks all public access |
| `aws_s3_bucket_versioning` | Enables object versioning |
| `aws_s3_bucket_server_side_encryption_configuration` | AES-256 encryption at rest |
| `aws_s3_bucket_lifecycle_configuration` | Transitions to IA → Glacier; expires old versions |
| `aws_s3_bucket_cors_configuration` | Optional CORS rules |
| `aws_s3_bucket_policy` | Enforces HTTPS-only access |

## Usage

```hcl
module "storage_assets" {
  source = "../../modules/storage"

  project       = "myapp"
  environment   = "prod"
  bucket_suffix = "assets"

  force_destroy     = false
  versioning_enabled = true

  lifecycle_transition_ia_days      = 30
  lifecycle_transition_glacier_days = 90
  lifecycle_expiration_days         = 365
}
```

## Inputs

See [`variables.tf`](./variables.tf).

## Outputs

See [`outputs.tf`](./outputs.tf).
