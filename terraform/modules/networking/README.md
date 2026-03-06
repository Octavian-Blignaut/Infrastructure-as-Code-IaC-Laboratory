# Module: networking

Creates a production-ready AWS network topology.

## Resources created

| Resource | Purpose |
|---|---|
| `aws_vpc` | Isolated virtual network |
| `aws_subnet` (public × N) | Internet-reachable subnets – hosts the ALB |
| `aws_subnet` (private × N) | Isolated subnets – hosts EC2, RDS |
| `aws_internet_gateway` | Connects the VPC to the internet |
| `aws_eip` / `aws_nat_gateway` | Outbound internet access for private subnets |
| `aws_route_table` (public) | Routes public subnet traffic to the IGW |
| `aws_route_table` (private × N) | Routes private subnet traffic to a NAT GW |
| `aws_security_group` (alb) | Allows HTTP/HTTPS from the internet |
| `aws_security_group` (app) | Allows application port from the ALB SG |
| `aws_security_group` (db) | Allows PostgreSQL from the app SG |

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"

  project     = "myapp"
  environment = "dev"

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]

  enable_nat_gateway = true
  single_nat_gateway = true   # set false in prod for full HA
}
```

## Inputs

See [`variables.tf`](./variables.tf) for the full list with descriptions,
types, and defaults.

## Outputs

See [`outputs.tf`](./outputs.tf) for the full list of exported values.
