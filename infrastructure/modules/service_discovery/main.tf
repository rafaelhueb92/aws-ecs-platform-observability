resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = "internal.local"
  description = "Service discovery for internal microservices"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "inventory" {
  name = "inventory"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id
    
    dns_records {
      ttl  = 60
      type = "A" # The "A" record maps the service name to the Task IP
    }
  }

  health_check_custom_config {
    failure_threshold = 1 # Immediate removal if ECS says it's dead
  }
}