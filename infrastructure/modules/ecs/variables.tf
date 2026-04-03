variable "project_name" {
  description = "Project name for tagging and resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., staging, prod)."
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources."
  type        = string
}
