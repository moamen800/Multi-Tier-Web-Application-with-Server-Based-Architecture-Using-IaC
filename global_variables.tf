####################################### Provider Variables #######################################
# Configuration for AWS provider
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1" # Default region
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  default     = "default" # Default profile
}

variable "image_id" {
  description = "The ID of the AMI to use"
  type        = string
  default     = "ami-0866a3c8686eaeeba"
}
