# Public Route Table and Associations
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }

  tags = {
    Name = "Route Table for Public Subnet",
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

# Splunk Route Table and Associations
resource "aws_route_table" "splunk_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.splunk.id
  }

  tags = {
    Name = "Route Table for Splunk App"
  }

}

resource "aws_route_table_association" "splunk_subnet_association" {
  for_each       = aws_subnet.splunk_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.splunk_route_table.id
}