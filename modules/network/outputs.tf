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
