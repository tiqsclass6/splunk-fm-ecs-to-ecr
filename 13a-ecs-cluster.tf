resource "aws_ecs_cluster" "splunk" {
  name   = "splunk"
  region = var.aws_region

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}