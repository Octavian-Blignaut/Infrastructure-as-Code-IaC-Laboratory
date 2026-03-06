##############################################################################
# modules/compute/variables.tf
##############################################################################

variable "project" {
  description = "Short name used to prefix every resource."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev | staging | prod)."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to deploy into."
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of public subnets for the Application Load Balancer."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of private subnets for the Auto Scaling Group."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security-group ID to attach to the ALB."
  type        = string
}

variable "app_security_group_id" {
  description = "Security-group ID to attach to EC2 instances."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 launch template."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the Auto Scaling Group."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access (optional)."
  type        = string
  default     = null
}

variable "user_data" {
  description = "Base64-encoded user-data script to run on instance launch."
  type        = string
  default     = null
}

variable "asg_min_size" {
  description = "Minimum number of EC2 instances in the ASG."
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in the ASG."
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances in the ASG."
  type        = number
  default     = 2
}

variable "health_check_path" {
  description = "HTTP path used by the ALB target group health check."
  type        = string
  default     = "/health"
}

variable "app_port" {
  description = "TCP port the application listens on."
  type        = number
  default     = 8080
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
