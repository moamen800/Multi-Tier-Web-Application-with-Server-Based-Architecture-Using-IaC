
####################################### VPC Outputs #######################################
# Output the VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id # Reference to the created VPC
}

####################################### Subnet Outputs #######################################
# Output the Public Subnet IDs
output "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  value       = [for subnet in aws_subnet.public_subnets : subnet.id] # Loop to extract all public subnet IDs
}

# Output the Private Subnet IDs
output "private_subnet_ids" {
  description = "List of Private Subnet IDs"
  value       = [for subnet in aws_subnet.private_subnets : subnet.id] # Loop to extract all private subnet IDs
}

####################################### Gateway Outputs #######################################
# Output the Internet Gateway ID
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.internet_gateway.id # Reference to the created IGW
}

# Output the NAT Gateway ID
output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat_gateway.id # Reference to the created NAT Gateway
}

# Output the Elastic IP of the NAT Gateway
output "nat_gateway_eip" {
  description = "Elastic IP of the NAT Gateway"
  value       = aws_eip.nat_gateway_eip.public_ip # Public IP assigned to the NAT Gateway
}

