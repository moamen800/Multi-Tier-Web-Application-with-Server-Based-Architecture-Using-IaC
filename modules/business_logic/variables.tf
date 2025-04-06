####################################### VPC Variables #######################################

# The VPC ID to associate the resources with
variable "vpc_id" {
  description = "The VPC ID"
  type        = string # A string type to hold the ID of the VPC
}

# List of Public Subnet IDs where the Application Load Balancer and other resources will reside
variable "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  type        = list(string) # A list of strings to hold multiple subnet IDs
}

variable "private_subnets_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

# Security group ID for the presentation business_logiclication load balancer (ALB)
variable "business_logic_alb_sg_id" {
  description = "Security group ID for the presentation business_logiclication load balancer"
  type        = string # A string type to hold the ID of the security group associated with the ALB
}

# The ID of the presentation security group for instance
variable "business_logic_sg_id" {
  description = "The ID of the presentation security group for instances"
  type        = string # A string type to hold the security group ID for the EC2 instances
}

variable "image_id" {
  description = "The AMI ID to use for the instances"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "DocumentDB_sg_id" {
  description = "The ID of the presentation security group for instances"
  type        = string
}