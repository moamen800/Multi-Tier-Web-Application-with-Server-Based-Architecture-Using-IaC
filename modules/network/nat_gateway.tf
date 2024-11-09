
####################################### NAT Gateway #######################################
# Allocate an Elastic IP (EIP) for the NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc" # Allocate EIP within the VPC

  tags = {
    Name = "nat_gateway_eip"
  }
}
# Create a NAT Gateway to enable internet access for private subnets
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id                 # Use the allocated EIP
  subnet_id     = aws_subnet.public_subnets["us-east-1a"].id # Attach to a public subnet

  tags = {
    Name = "nat_gateway"
  }
}
