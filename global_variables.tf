variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for EC2 instances"
  type        = string
}

variable "image_id" {
  description = "The ID of the AMI to use"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Map of public subnets by availability zone"
  type        = map(string)
}

variable "private_subnets" {
  description = "Map of private subnets by availability zone"
  type        = map(string)
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate in us-east-1 (required for CloudFront)"
  type        = string
}

variable "domain_name" {
  description = "The domain name to use for the CloudFront distribution"
  type        = string
}

variable "record_name" {
  description = "The name of the record to create in Route 53"
  type        = string
}

variable "cloudfront_aliases" {
  description = "List of alternate domain names (CNAMEs) for CloudFront distribution"
  type        = list(string)
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}