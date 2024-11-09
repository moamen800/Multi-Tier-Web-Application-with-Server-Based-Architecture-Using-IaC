
####################################### Internet Gateway #######################################
# Create an Internet Gateway to provide public subnets with internet access
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}