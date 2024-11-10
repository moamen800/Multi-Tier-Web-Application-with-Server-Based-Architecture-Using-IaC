####################################### AMI Data Source #######################################
# Fetch the latest Amazon Linux 2 AMI ID using a filter
data "aws_ami" "latest_amazon_linux_2" {
  most_recent = true       # Fetch the most recent AMI
  owners      = ["amazon"] # Filter for AMIs owned by Amazon

  # Filter by name for Amazon Linux 2 AMI
  filter {
    name   = "name"                         # Filter by the AMI name
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # Filter for Amazon Linux 2 AMI (x86_64 architecture)
  }
}

####################################### Availability Zones Data Source #######################################
# Fetch the available availability zones in the region
data "aws_availability_zones" "available" {
  state = "available" # Only return AZs that are available (active)
}
