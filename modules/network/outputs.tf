####################################### VPC Outputs #######################################
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "vpc_cidr" {
  description = "CIDR block for the VPC"
  value       = aws_vpc.vpc.cidr_block
}


####################################### Subnet Outputs #######################################
output "public_subnet_web_ids" {
  description = "List of Public Subnet IDs"
  value       = [for subnet in aws_subnet.public_subnets_web : subnet.id] # Loop through public subnets and extract their IDs
}

output "public_subnet_app_ids" {
  description = "List of Private Subnet IDs"
  value       = [for subnet in aws_subnet.public_subnets_app : subnet.id] # Loop through private subnets and extract their IDs
}
