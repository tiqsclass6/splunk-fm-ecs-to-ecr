resource "aws_autoscaling_group" "splunk_asg" {
  name_prefix               = "splunk-asg"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 3
  vpc_zone_identifier       = [for i in aws_subnet.splunk_subnet : i.id]
  protect_from_scale_in     = true
  health_check_type         = "EC2"
  health_check_grace_period = 120


  launch_template {
    id      = aws_launch_template.splunk_lt.id
    version = "$Latest"
  }

  lifecycle { create_before_destroy = true }
}