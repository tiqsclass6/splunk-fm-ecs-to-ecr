resource "aws_ecs_task_definition" "splunk_task_definition" {
  family                   = "splunk-task-def"
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "3072"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.splunk_ecs_execution_task_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name              = "splunk"
      image             = "866340886126.dkr.ecr.us-east-1.amazonaws.com/tiqsclass6/splunk-ecs-to-ecr/splunk:latest"
      cpu               = 1024
      memory            = 3072
      memoryReservation = 2048
      gpu               = 1024
      essential         = true
      portMappings = [
        {
          appProtocol   = "http"
          containerPort = 8000
          hostPort      = 8000
          portName      = "splunk-web"
          protocol      = "tcp"
        },
        {
          appProtocol   = "http"
          containerPort = 8088
          hostPort      = 8088
          portName      = "splunk-hec"
          protocol      = "tcp"
        },
        {
          appProtocol   = "http"
          containerPort = 8089
          hostPort      = 8089
          portName      = "splunk-mgmt"
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "SPLUNK_PASSWORD"
          value = "tiqs_pwd_1"
        },
        {
          name  = "SPLUNK_START_ARGS"
          value = "--accept-license"
        },
        {
          name  = "SPLUNK_GENERAL_TERMS"
          value = "--accept-sgt-current-at-splunk-com"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.splunk_logs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}