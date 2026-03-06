##############################################################################
# modules/storage/variables.tf
##############################################################################

variable "project" {
  description = "Short name used to prefix every resource."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev | staging | prod)."
  type        = string
}

variable "bucket_suffix" {
  description = "Extra suffix appended to the bucket name (e.g. 'assets', 'logs')."
  type        = string
}

variable "force_destroy" {
  description = "Allow Terraform to delete a non-empty bucket (dev only)."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable S3 object versioning."
  type        = bool
  default     = true
}

variable "lifecycle_transition_ia_days" {
  description = "Days before objects are transitioned to STANDARD_IA storage."
  type        = number
  default     = 30
}

variable "lifecycle_transition_glacier_days" {
  description = "Days before objects are transitioned to GLACIER storage."
  type        = number
  default     = 90
}

variable "lifecycle_expiration_days" {
  description = "Days before non-current versions are permanently deleted (0 = disabled)."
  type        = number
  default     = 365
}

variable "cors_allowed_origins" {
  description = "List of origins allowed via CORS (empty list disables CORS configuration)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
