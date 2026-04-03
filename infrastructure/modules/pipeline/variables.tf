# infrastructure/modules/codedeploy/variables.tf

variable "project_name" {
  description = "Project name used as prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name (staging, production)"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS Cluster to deploy to"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS Service to deploy to (Order API)"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of the ALB Listener that CodeDeploy will manage"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics (e.g. app/my-alb/1234567890)"
  type        = string
}

variable "target_group_blue_name" {
  description = "Name of the BLUE target group"
  type        = string
}

variable "target_group_green_name" {
  description = "Name of the GREEN target group"
  type        = string
}

variable "deployment_config_name" {
  description = "CodeDeploy deployment config strategy"
  type        = string
  default     = "CodeDeployDefault.ECSCanary10Percent5Minutes"
  # Options:
  # CodeDeployDefault.ECSLinear10PercentEvery1Minutes  → Slow, safe
  # CodeDeployDefault.ECSCanary10Percent5Minutes       → 10% first, then 100% (Recommended)
  # CodeDeployDefault.ECSAllAtOnce                     → Fast, risky (never use in prod)
}

variable "termination_wait_time" {
  description = "Minutes to wait before terminating BLUE tasks after successful deployment"
  type        = number
  default     = 5
  # Staff tip: Set to 0 for staging, 5-10 for production
  # This is the "graceful drain" window for in-flight requests
}

variable "error_rate_threshold" {
  description = "Number of 5xx errors per minute to trigger auto rollback"
  type        = number
  default     = 10
}