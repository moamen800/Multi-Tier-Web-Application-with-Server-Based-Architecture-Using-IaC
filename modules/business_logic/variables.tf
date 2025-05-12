variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  type        = list(string)
}

variable "private_subnets_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "business_logic_alb_sg_id" {
  description = "Security group ID for the presentation business_logiclication load balancer"
  type        = string
}

variable "business_logic_sg_id" {
  description = "The ID of the presentation security group for instances"
  type        = string
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