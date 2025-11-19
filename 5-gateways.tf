resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_eip" "splunk" {
  domain = "vpc"
}

#Create NAT Gateway
resource "aws_nat_gateway" "splunk" {
  depends_on    = [aws_subnet.public_subnet]
  allocation_id = aws_eip.splunk.id
  subnet_id     = aws_subnet.public_subnet["public_subnet_1"].id
}