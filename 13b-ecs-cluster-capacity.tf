resource "aws_ecs_capacity_provider" "splunk_cp" {
  name = "splunk-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.splunk_asg.arn
    managed_termination_protection = "ENABLED"
    managed_draining               = "DISABLED"

    managed_scaling {
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 2
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "attach" {
  cluster_name       = aws_ecs_cluster.splunk.name
  capacity_providers = [aws_ecs_capacity_provider.splunk_cp.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.splunk_cp.name
    weight            = 1
    base              = 0
  }
}