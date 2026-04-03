terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "aws-ecs-platform-observability"
    }
  }
}

module "networking" {
  source       = "../../modules/networking"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}

module "ecr" {
  source       = "../../modules/ecr"
  project_name = var.project_name
  environment  = var.environment
  services     = ["order-api", "inventory-api"]
}

module "service_discovery" {
  source       = "../../modules/service_discovery"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
}

module "ecs" {
  source              = "../../modules/ecs"
  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  public_subnet_ids   = module.networking.public_subnet_ids
  order_api_ecr_url   = module.ecr.repository_urls["order-api"]
  inventory_ecr_url   = module.ecr.repository_urls["inventory-api"]
  service_discovery_namespace_id = module.service_discovery.namespace_id
  inventory_service_discovery_id = module.service_discovery.inventory_service_id
}

module "codedeploy" {
  source = "../../modules/codedeploy"

  project_name    = var.project_name
  environment     = var.environment

  ecs_cluster_name        = module.ecs.cluster_name
  ecs_service_name        = module.ecs.order_api_service_name
  alb_listener_arn        = module.ecs.alb_listener_arn
  alb_arn_suffix          = module.ecs.alb_arn_suffix
  target_group_blue_name  = module.ecs.target_group_blue_name
  target_group_green_name = module.ecs.target_group_green_name

  # Staging settings (more aggressive = faster feedback)
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"
  termination_wait_time  = 5
  error_rate_threshold   = 10
}