variable "aws_region" {
  description = "AWS region for provider resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID for service discovery namespace"
  type        = string
}

variable "project_name" {
  description = "Project name used as prefix for all resources"
  type        = string
  default     = "ecs-platform"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}