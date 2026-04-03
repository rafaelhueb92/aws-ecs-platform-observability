# infrastructure/modules/codedeploy/outputs.tf

output "codedeploy_app_name" {
  description = "CodeDeploy Application name"
  value       = aws_codedeploy_app.main.name
}

output "deployment_group_name" {
  description = "CodeDeploy Deployment Group name"
  value       = aws_codedeploy_deployment_group.main.deployment_group_name
}

output "codedeploy_role_arn" {
  description = "IAM Role ARN used by CodeDeploy"
  value       = aws_iam_role.codedeploy.arn
}

output "cloudwatch_alarm_name" {
  description = "CloudWatch alarm that triggers auto rollback"
  value       = aws_cloudwatch_metric_alarm.error_rate.alarm_name
}