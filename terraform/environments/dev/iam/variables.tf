variable "project" {
  description = "Short name used to prefix every resource."
  type        = string
}

variable "environment" {
  description = "Environment name (dev/staging/prod)."
  type        = string
}

variable "enable_iam_lab" {
  description = "Enable IAM lab resources."
  type        = bool
  default     = false
}

variable "iam_lab_user_name" {
  description = "IAM username for lab experimentation."
  type        = string
}

variable "assets_bucket_arn" {
  description = "ARN of the dev assets S3 bucket for policy scoping."
  type        = string
}
