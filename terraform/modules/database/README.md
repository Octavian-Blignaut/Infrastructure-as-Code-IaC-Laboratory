# Module: database

Creates a managed PostgreSQL database on Amazon RDS with production-grade
defaults.

## Resources created

| Resource | Purpose |
|---|---|
| `aws_db_subnet_group` | Confines RDS to private subnets |
| `aws_db_parameter_group` | Custom PostgreSQL parameters (logging, pg_stat_statements) |
| `aws_db_instance` | PostgreSQL RDS instance |

## Production defaults

* **Encrypted at rest** – `storage_encrypted = true` (AES-256).
* **Not publicly accessible** – traffic is restricted to the db security group.
* **Performance Insights** enabled (7-day retention).
* **Automated backups** (configurable retention, default 7 days).
* **Deletion protection** enabled by default.
* **gp3 storage** for better price/performance vs gp2.

## Usage

```hcl
module "database" {
  source = "../../modules/database"

  project     = "myapp"
  environment = "prod"

  vpc_id               = module.networking.vpc_id
  private_subnet_ids   = module.networking.private_subnet_ids
  db_security_group_id = module.networking.db_security_group_id

  db_password = var.db_password   # supply via TF_VAR_db_password

  instance_class          = "db.t3.small"
  allocated_storage       = 50
  multi_az                = true
  backup_retention_period = 30
  deletion_protection     = true
  skip_final_snapshot     = false
}
```

## Inputs

See [`variables.tf`](./variables.tf).

## Outputs

See [`outputs.tf`](./outputs.tf).
