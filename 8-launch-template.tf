data "aws_ami" "amzn-linux-2023-ecs-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-2023.*x86_64"]
  }
}

resource "aws_launch_template" "splunk_lt" {
  name_prefix   = "splunk-lt-"
  image_id      = data.aws_ami.amzn-linux-2023-ecs-ami.id
  instance_type = "m6i.large"

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_profile.name
  }

  vpc_security_group_ids = [aws_security_group.splunk_sg.id]

  # For aws_launch_template, user_data must be BASE64-encoded
  user_data = base64encode(
    templatefile("${path.module}/scripts/splunk-userdata.tpl", {
      ecs_cluster  = aws_ecs_cluster.splunk.name
      infra_script = file("${path.module}/scripts/2-ecs-agent.sh")
    })
  )
}
