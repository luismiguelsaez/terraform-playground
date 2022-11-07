variable "environment" {
  type        = string
  description = "Environment name"
  default     = "test"
}

variable "s3_bucket_lifecycle_enable" {
  type        = bool
  description = "Enable S3 bucket lifecycle configuration"
  default     = true
}
variable "s3_bucket_lifecycle" {
  type        = map(string)
  description = "S3 bucket lifecycle transition days"
  default     = {
    STANDARD_IA = 30
    DELETE      = 60
  }
}
