####################################### VPC Variables #######################################

# The VPC ID to associate the resources with
variable "vpc_id" {
  description = "The VPC ID"
  type        = string # A string type to hold the ID of the VPC
}

# List of Public Subnet IDs where the Application Load Balancer and other resources will reside
variable "public_subnet_web_ids" {
  description = "List of Public Subnet IDs"
  type        = list(string) # A list of strings to hold multiple subnet IDs
}

# Security group ID for the web application load balancer (ALB)
variable "web_alb_sg_id" {
  description = "Security group ID for the web application load balancer"
  type        = string # A string type to hold the ID of the security group associated with the ALB
}

# The ID of the web security group for instance
variable "web_sg_id" {
  description = "The ID of the web security group for instances"
  type        = string # A string type to hold the security group ID for the EC2 instances
}

variable "image_id" {
  description = "The AMI ID to use for the instances"
  type        = string
}

variable "vpc_cidr" {
  description = "the cidr of the vpc"
  type        = string
}