resource "aws_cloudwatch_log_group" "splunk_logs" {
  name              = "/ecs/splunk"
  retention_in_days = 14
}