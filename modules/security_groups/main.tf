####################################### ALB Security Group (web_alb_sg) #######################################
# Security group for the Application Load Balancer (ALB)
resource "aws_security_group" "web_alb_sg" {
  vpc_id = var.vpc_id # Associate the security group with the specified VPC

  # HTTP Ingress (Port 80) – Allow incoming HTTP traffic to the ALB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic from anywhere (0.0.0.0/0)
  }

  # HTTPS Ingress (Port 443) – Allow incoming HTTPS traffic to the ALB
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic from anywhere (0.0.0.0/0)
  }

  tags = {
    Name = "web-alb-sg" # Tag for identifying the ALB security group
  }
}

####################################### Web Security Group (web_sg) #######################################
# Security group for the web instances behind the ALB
resource "aws_security_group" "web_sg" {
  vpc_id = var.vpc_id # Associate the security group with the specified VPC

  # Allow HTTP from ALB (Port 80) – Only ALB can send HTTP traffic to web instances
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_alb_sg.id] # Allow traffic from the ALB security group
  }

  # Allow HTTPS from ALB (Port 443) – Only ALB can send HTTPS traffic to web instances
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.web_alb_sg.id] # Allow traffic from the ALB security group
  }

  # Allow SSH (Port 22) – Use with caution, allows SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (0.0.0.0/0)
  }

  tags = {
    Name = "web-sg" # Tag for identifying the web instance security group
  }
}
