####################################### VPC Variables #######################################

# List of Public Subnet IDs where the Application Load Balancer and other resources will reside
variable "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  type        = list(string) # A list of strings to hold multiple subnet IDs
}

# Security group ID for the presentation application load balancer (ALB)
variable "Monitoring_sg_id" {
  description = "Security group ID for the presentation application load balancer"
  type        = string # A string type to hold the ID of the security group associated with the ALB
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
  default     = "t3.medium"
}
