resource "aws_ecs_service" "splunk_svc" {
  name                   = "splunk-service"
  cluster                = aws_ecs_cluster.splunk.id
  task_definition        = aws_ecs_task_definition.splunk_task_definition.arn
  desired_count          = 1
  enable_execute_command = true
  force_new_deployment   = true
  force_delete           = true

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.splunk_cp.name
    weight            = 1
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = [for i in aws_subnet.splunk_subnet : i.id]
    security_groups  = [aws_security_group.splunk_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.splunk_tg.arn
    container_name   = "splunk"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.splunk_listener]
}