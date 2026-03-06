# Module: compute

Creates a scalable, self-healing application tier on AWS.

## Resources created

| Resource | Purpose |
|---|---|
| `aws_iam_role` / `aws_iam_instance_profile` | Grants EC2 instances SSM and CloudWatch access |
| `aws_launch_template` | Defines instance configuration (AMI, type, SG, IMDSv2) |
| `aws_autoscaling_group` | Maintains desired instance count across AZs |
| `aws_autoscaling_policy` | Target-tracking policy on CPU utilisation (60 %) |
| `aws_lb` (ALB) | Internet-facing Application Load Balancer |
| `aws_lb_target_group` | Registers ASG instances with health checks |
| `aws_lb_listener` | HTTP listener forwarding to the target group |

## Security highlights

* **IMDSv2 enforced** – prevents SSRF-based metadata exploits.
* **No public IPs** – instances live in private subnets; all traffic flows through the ALB.
* **SSM Session Manager** – removes the need for a bastion host or SSH key exposure.

## Usage

```hcl
module "compute" {
  source = "../../modules/compute"

  project     = "myapp"
  environment = "dev"

  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  alb_security_group_id = module.networking.alb_security_group_id
  app_security_group_id = module.networking.app_security_group_id

  ami_id        = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"

  asg_min_size         = 1
  asg_max_size         = 4
  asg_desired_capacity = 2
}
```

## Inputs

See [`variables.tf`](./variables.tf).

## Outputs

See [`outputs.tf`](./outputs.tf).
