####################################### VPC #######################################
# Create the VPC with a defined CIDR block (IP range)
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr # Set the IP range for the VPC

  tags = {
    Name      = var.vpc_name # Name tag for VPC
    Terraform = "true"       # Indicate resource managed by Terraform
  }
}

####################################### Public Subnets WEB #######################################
# Create public subnets across availability zones
resource "aws_subnet" "public_subnets_web" {
  for_each                = var.public_subnets_web # Create one subnet per AZ
  vpc_id                  = aws_vpc.vpc.id     # Associate with the VPC
  cidr_block              = each.value         # Assign IP range from the map
  map_public_ip_on_launch = true               # Assign public IP to instances
  availability_zone       = each.key           # Set AZ for each subnet

  tags = {
    Name      = "${each.key}_public_subnet_web" # Name tag with AZ
    Terraform = "true"
  }
}

####################################### Public Route Table #######################################
# Create a public route table to route traffic through the Internet Gateway
resource "aws_route_table" "public_rt_web" {
  vpc_id = aws_vpc.vpc.id # Reference the VPC for the route table

  tags = {
    Name      = "public_route_table"
    Terraform = "true"
  }
}

# Add a default route to the Internet Gateway for the public route table
resource "aws_route" "public_internet_access_web" {
  route_table_id         = aws_route_table.public_rt_web.id
  destination_cidr_block = "0.0.0.0/0" # Route all traffic to the IGW
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_assoc" {
  for_each       = aws_subnet.public_subnets_web # Iterate over public subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt_web.id
}


####################################### Public Subnets APP #######################################
# Create public subnets across availability zones
resource "aws_subnet" "public_subnets_app" {
  for_each                = var.public_subnets_app # Create one subnet per AZ
  vpc_id                  = aws_vpc.vpc.id     # Associate with the VPC
  cidr_block              = each.value         # Assign IP range from the map
  map_public_ip_on_launch = true               # Assign public IP to instances
  availability_zone       = each.key           # Set AZ for each subnet

  tags = {
    Name      = "${each.key}_public_subnet_app" # Name tag with AZ
    Terraform = "true"
  }
}

####################################### Public Route Table #######################################
# Create a public route table to route traffic through the Internet Gateway
resource "aws_route_table" "public_rt_app" {
  vpc_id = aws_vpc.vpc.id # Reference the VPC for the route table

  tags = {
    Name      = "public_route_table"
    Terraform = "true"
  }
}

# Add a default route to the Internet Gateway for the public route table
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt_app.id
  destination_cidr_block = "0.0.0.0/0" # Route all traffic to the IGW
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_assoc_app" {
  for_each       = aws_subnet.public_subnets_app # Iterate over public subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt_app.id
}

####################################### Create App NACL #######################################
# resource "aws_network_acl" "app_nacl" {
#   vpc_id = aws_vpc.vpc.id # Reference the VPC

#   tags = {
#     Name = "app-nacl"
#   }
# }

# Inbound Rule for App NACL (Allow all traffic from 10.0.0.0/16)
# resource "aws_network_acl_rule" "app_nacl_inbound" {
#   network_acl_id = aws_network_acl.app_nacl.id
#   rule_number    = 100
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = var.vpc_cidr
#   from_port      = 0
#   to_port        = 65535
#   egress         = false
# }

# # Outbound Rule for App NACL (Allow all traffic to 10.0.0.0/16)
# resource "aws_network_acl_rule" "app_nacl_outbound" {
#   network_acl_id = aws_network_acl.app_nacl.id
#   rule_number    = 110
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 0
#   to_port        = 65535
#   egress         = true
# }

# Associate the NACL with Private Subnets
# resource "aws_network_acl_association" "app_nacl_assoc" {
#   for_each       = aws_subnet.private_subnets # Iterate over both private subnets
#   subnet_id      = each.value.id
#   network_acl_id = aws_network_acl.app_nacl.id # Associate the app NACL with private subnets
# }

####################################### Internet Gateway #######################################
# Create an Internet Gateway to provide public subnets with internet access
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id # Attach the IGW to the VPC

  tags = {
    Name = "igw"
  }
}
