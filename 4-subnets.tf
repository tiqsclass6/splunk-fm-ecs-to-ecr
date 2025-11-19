resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  for_each                = var.public_subnet_config
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
}


resource "aws_subnet" "splunk_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  for_each                = var.private_subnet_config
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = false
}