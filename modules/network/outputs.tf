####################################### VPC Outputs #######################################
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

####################################### Subnet Outputs #######################################
output "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  value       = [for subnet in aws_subnet.public_subnets : subnet.id] # Loop through public subnets and extract their IDs
}

output "private_subnet_ids" {
  description = "List of Private Subnet IDs"
  value       = [for subnet in aws_subnet.private_subnets : subnet.id] # Loop through private subnets and extract their IDs
}


####################################### Gateway Outputs #######################################
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.internet_gateway.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat_gateway.id
}

output "nat_gateway_eip" {
  description = "Elastic IP of the NAT Gateway"
  value       = aws_eip.nat_gateway_eip.public_ip
}
