resource "aws_lb" "splunk_alb" {
  name                       = "splunk-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.splunk_alb_sg.id]
  subnets                    = [for i in aws_subnet.public_subnet : i.id]
  enable_deletion_protection = false
}

resource "aws_lb_listener" "splunk_listener" {
  load_balancer_arn = aws_lb.splunk_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.splunk_tg.arn
  }
}