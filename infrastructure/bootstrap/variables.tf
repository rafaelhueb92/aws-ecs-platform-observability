variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
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