# Infrastructure-as-Code IaC Laboratory

A dedicated space for testing cloud architectures, practicing automation, and breaking things (so I can learn how to fix them).

This repository is structured as **production-grade, modular Terraform**. Every piece of infrastructure is a reusable module; environments are thin wrappers that call those modules with environment-specific values.

---

## Architecture overview

```
                         ┌─────────────────────────────────┐
                         │            AWS VPC               │
                         │                                  │
   Internet ──► IGW ──►  │  ┌──────────────────────────┐   │
                         │  │   Public subnets (×3 AZ)  │   │
                         │  │   Application Load Balancer│   │
                         │  └────────────┬───────────────┘   │
                         │               │ HTTP               │
                         │  ┌────────────▼───────────────┐   │
                         │  │  Private subnets (×3 AZ)   │   │
                         │  │  Auto Scaling Group (EC2)  │   │
                         │  │  RDS PostgreSQL (Multi-AZ) │   │
                         │  └────────────────────────────┘   │
                         │                  │ NAT GW          │
                         └──────────────────┼─────────────────┘
                                            ▼
                                        Internet
```

### S3 buckets (separate from VPC)
* **assets** – static assets / user uploads.
* **logs** *(prod only)* – application / access logs.

---

## Repository layout

```
terraform/
├── modules/                  # Reusable building blocks
│   ├── networking/           # VPC, subnets, IGW, NAT GW, security groups
│   ├── compute/              # ALB, Launch Template, Auto Scaling Group
│   ├── database/             # RDS PostgreSQL, subnet group, parameter group
│   └── storage/              # S3 bucket (versioned, encrypted, lifecycle)
└── environments/
    ├── dev/                  # Dev environment (minimal cost, easy teardown)
    └── prod/                 # Production environment (HA, full backups)
```

---

## Modules

| Module | Key resources |
|---|---|
| [`networking`](terraform/modules/networking/) | VPC · subnets · IGW · NAT GW · security groups |
| [`compute`](terraform/modules/compute/) | ALB · Launch Template · ASG · IAM instance profile |
| [`database`](terraform/modules/database/) | RDS PostgreSQL · subnet group · parameter group |
| [`storage`](terraform/modules/storage/) | S3 bucket · versioning · encryption · lifecycle · HTTPS policy |

---

## Prerequisites

| Tool | Minimum version |
|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | 1.6.0 |
| [AWS CLI](https://aws.amazon.com/cli/) | 2.x |
| AWS credentials | configured via `~/.aws/credentials` or environment variables |

---

## Getting started

### 1 – Bootstrap remote state (once per account)

Before using either environment you need an S3 bucket and a DynamoDB table for
Terraform remote state.  Create them manually (or with a separate bootstrap
script) then update the `backend "s3"` block in
`terraform/environments/<env>/providers.tf` with the real bucket name and table
name.

### 2 – Deploy the dev environment

```bash
# Set your DB password via an environment variable (never commit it)
export TF_VAR_db_password="$(openssl rand -base64 24)"

cd terraform/environments/dev

# Initialise – downloads providers and resolves module sources
terraform init

# Preview changes
terraform plan

# Apply
terraform apply
```

### 3 – Deploy the prod environment

```bash
# Supply the password from your secrets manager, e.g.:
export TF_VAR_db_password="$(aws secretsmanager get-secret-value \
  --secret-id prod/iaclab/db_password --query SecretString --output text)"

cd terraform/environments/prod
terraform init
terraform plan
terraform apply
```

---

## Dev vs Prod differences

| Setting | Dev | Prod |
|---|---|---|
| NAT Gateways | 1 (cost saving) | 1 per AZ (HA) |
| EC2 instance type | `t3.micro` | `t3.small` |
| ASG desired capacity | 1 | 3 |
| RDS Multi-AZ | ✗ | ✓ |
| Backup retention | 1 day | 30 days |
| Deletion protection | ✗ | ✓ |
| S3 force-destroy | ✓ | ✗ |
| Log bucket | ✗ | ✓ |

---

## Security highlights

* **IMDSv2 enforced** on all EC2 instances (prevents SSRF metadata exploits).
* **No public IPs** on EC2 instances – all ingress flows through the ALB.
* **SSM Session Manager** – no bastion host or open SSH ports required.
* **S3 public access blocked** at the bucket level.
* **HTTPS-only S3 policy** – all non-TLS requests are denied.
* **RDS encrypted at rest** and not publicly accessible.
* **Secrets never in code** – DB password supplied via `TF_VAR_db_password`.

