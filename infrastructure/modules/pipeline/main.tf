resource "aws_iam_role" "codedeploy" {
  name = "${var.project_name}-${var.environment}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codedeploy.amazonaws.com" }
    }]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-codedeploy-role"
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy_ecs" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# CodeDeploy Application
resource "aws_codedeploy_app" "main" {
  name             = "${var.project_name}-${var.environment}"
  compute_platform = "ECS"

  tags = {
    Name = "${var.project_name}-${var.environment}-codedeploy-app"
  }
}

# CloudWatch Alarm - Monitors 5xx errors during deployment
# If this alarm fires, CodeDeploy automatically rolls back to BLUE
resource "aws_cloudwatch_metric_alarm" "error_rate" {
  alarm_name          = "${var.project_name}-${var.environment}-5xx-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = var.error_rate_threshold
  alarm_description   = "Triggers CodeDeploy rollback if 5xx errors spike during deployment"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-5xx-alarm"
  }
}

# CodeDeploy Deployment Group - Blue/Green Strategy
resource "aws_codedeploy_deployment_group" "main" {
  app_name               = aws_codedeploy_app.main.name
  deployment_group_name  = "${var.project_name}-${var.environment}-dg"
  service_role_arn       = aws_iam_role.codedeploy.arn

  deployment_config_name = var.deployment_config_name

  # ECS Service to deploy to
  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  # Blue/Green deployment settings
  blue_green_deployment_config {
    deployment_ready_option {
      # Immediately shift traffic after GREEN is healthy
      # Change to STOP_DEPLOYMENT for manual approval
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      # Wait 5 minutes before killing BLUE containers
      # This allows in-flight requests to complete (graceful drain)
      termination_wait_time_in_minutes = var.termination_wait_time
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  # ALB configuration - CodeDeploy manages traffic shifting
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.alb_listener_arn]
      }

      target_group {
        name = var.target_group_blue_name
      }

      target_group {
        name = var.target_group_green_name
      }
    }
  }

  # Auto Rollback - If the CloudWatch alarm fires, rollback to BLUE
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  # Link the CloudWatch alarm to this deployment group
  alarm_configuration {
    alarms  = [aws_cloudwatch_metric_alarm.error_rate.name]
    enabled = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-deployment-group"
  }
}