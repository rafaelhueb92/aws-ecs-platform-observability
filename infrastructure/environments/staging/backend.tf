terraform {
  backend "s3" {
    bucket         = "ecs-platform-terraform-state-staging"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}