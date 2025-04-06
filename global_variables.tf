####################################### Provider Variables #######################################
# Configuration for AWS provider
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "eu-west-1" # Default region
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  default     = "default" # Default profile
}

variable "image_id" {
  description = "The ID of the AMI to use"
  type        = string
  default     = "ami-0df368112825f8d8f"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The name of the key pair to use for EC2 instances"
  type        = string
  default     = "keypair_Ireland"
}
