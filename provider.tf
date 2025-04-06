####################################### Provider Configuration #######################################
provider "aws" {
  region  = var.aws_region  # AWS region (eu-west-1)
  profile = var.aws_profile # AWS CLI profile to use for authentication
}