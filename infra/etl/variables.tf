variable "env" {
  description = "Environment (e.g., dev, prod)"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-central-1"
}

variable "s3_postfix" {
  description = "Postfix for S3 bucket names to ensure uniqueness"
  type        = string
}