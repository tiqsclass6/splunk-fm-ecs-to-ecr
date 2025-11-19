resource "aws_lb_target_group" "splunk_tg" {
  name        = "splunk-tg"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "ip"
  protocol    = "HTTP"
  port        = 8000

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
    interval            = 50
    timeout             = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}