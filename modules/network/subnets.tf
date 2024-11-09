

####################################### Public Subnets #######################################
# Create public subnets across availability zones
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets # Create one subnet per AZ
  vpc_id                  = aws_vpc.vpc.id     # Associate with the VPC
  cidr_block              = each.value         # Directly assign IP range
  map_public_ip_on_launch = true               # Assign public IP to instances
  availability_zone       = each.key           # Set AZ for the subnet

  tags = {
    Name      = "${each.key}_public_subnet" # Name tag with AZ
    Terraform = "true"
  }
}
####################################### Public Route Table #######################################
# Create a public route table to route traffic through the Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "public_route_table"
    Terraform = "true"
  }
}

# Add a default route to the Internet Gateway for the public route table
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0" # Route all traffic to the IGW
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_assoc" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}



####################################### Private Subnets #######################################
# Create private subnets across availability zones
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets # Create one subnet per AZ
  vpc_id            = aws_vpc.vpc.id      # Associate with the VPC
  cidr_block        = each.value          # Directly assign IP range
  availability_zone = each.key            # Set AZ for the subnet

  tags = {
    Name      = "${each.key}_private_subnet" # Name tag with AZ
    Terraform = "true"
  }
}
####################################### Private Route Table #######################################
# Create a private route table for internal traffic and NAT Gateway access
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "private_route_table"
    Terraform = "true"
  }
}

# Route outbound traffic from private subnets to the NAT Gateway
resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0" # Route all outbound traffic to the NAT Gateway
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_assoc" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}


