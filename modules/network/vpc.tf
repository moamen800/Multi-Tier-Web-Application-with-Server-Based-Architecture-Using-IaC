####################################### VPC #######################################
# Create the VPC with a defined CIDR block (IP range)
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr # Set the IP range for the VPC

  tags = {
    Name      = var.vpc_name # Name tag for VPC
    Terraform = "true"       # Indicate resource managed by Terraform
  }
}