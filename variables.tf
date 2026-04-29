variable "project_name" {
  description = "Short name used as a prefix for all created resources."
  type        = string
  default     = "luit-api"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "lambda_log_retention_days" {
  description = "How long to retain CloudWatch logs for the Lambda."
  type        = number
  default     = 14
}

variable "throttle_rate_limit" {
  description = "API Gateway steady-state requests per second."
  type        = number
  default     = 100
}

variable "throttle_burst_limit" {
  description = "API Gateway burst capacity."
  type        = number
  default     = 200
}
