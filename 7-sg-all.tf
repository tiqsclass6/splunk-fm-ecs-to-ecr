resource "aws_security_group" "splunk_sg" {
  name        = "splunk-sg"
  description = "Security group for Splunk instances"
  vpc_id      = aws_vpc.main_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "splunk_ingress" {
  security_group_id            = aws_security_group.splunk_sg.id
  referenced_security_group_id = aws_security_group.splunk_alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 8000
  to_port                      = 8000
}

# resource "aws_vpc_security_group_ingress_rule" "splunk_ingress" {
#   security_group_id            = aws_security_group.splunk_sg.id
#   referenced_security_group_id = aws_security_group.splunk_alb_sg.id
#   ip_protocol                  = "tcp"
#   from_port                    = 8088
#   to_port                      = 8088
# }

# resource "aws_vpc_security_group_ingress_rule" "splunk_ingress" {
#   security_group_id            = aws_security_group.splunk_sg.id
#   referenced_security_group_id = aws_security_group.splunk_alb_sg.id
#   ip_protocol                  = "tcp"
#   from_port                    = 8089
#   to_port                      = 8089
# }

resource "aws_vpc_security_group_egress_rule" "splunk_egress" {
  security_group_id = aws_security_group.splunk_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "splunk_alb_sg" {
  name        = "splunk-alb-sg"
  description = "Security group for Splunk ALB"
  vpc_id      = aws_vpc.main_vpc.id

}

resource "aws_vpc_security_group_ingress_rule" "splunk_alb_ingress" {
  security_group_id = aws_security_group.splunk_alb_sg.id
  description       = "HTTP"
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "splunk_alb_egress" {
  security_group_id = aws_security_group.splunk_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}