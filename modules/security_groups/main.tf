####################################### ALB Security Group (web_alb_sg) #######################################
# Security group for the Application Load Balancer (ALB)
resource "aws_security_group" "web_alb_sg" {
  name   = "web_alb_sg"
  vpc_id = var.vpc_id # Associate the security group with the specified VPC

  # HTTP Ingress (Port 80) – Allow incoming HTTP traffic to the ALB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic from anywhere (0.0.0.0/0)
  }

  # HTTPS Ingress (Port 443) – Allow incoming HTTPS traffic to the ALB
  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"] # Allow traffic from anywhere (0.0.0.0/0)
  # }

  tags = {
    Name = "web-alb-sg" # Tag for identifying the ALB security group
  }
}

####################################### Web Security Group (web_sg) #######################################
# Security group for the web instances behind the ALB
resource "aws_security_group" "web_sg" {
  name   = "web_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_alb_sg.id] # Allow traffic from the ALB security group
  }

  # ingress {
  #   from_port       = 443
  #   to_port         = 443
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.web_alb_sg.id] # Allow traffic from the ALB security group
  # }

  # Allow SSH (Port 22) – Use with caution, allows SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (0.0.0.0/0)
  }

  tags = {
    Name = "web-sg"
  }
}

####################################### ALB Security Group (app_alb_sg) #######################################
# Security group for the Application Load Balancer (ALB)
resource "aws_security_group" "app_alb_sg" {
  name   = "app-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] # Allow traffic from the web_sg and web_alb_sg Security Groups
  }

  tags = {
    Name = "app-alb-sg"
  }
}

####################################### app Security Group (app_sg) #######################################
# Security group for the app instances behind the Application Load Balancer
resource "aws_security_group" "app_sg" {
  name   = "app-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.app_alb_sg.id] # Allow traffic from the app_alb_sg security group
  }

  # Allow SSH (Port 22) – Use with caution, allows SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (0.0.0.0/0)
  }

  tags = {
    Name = "app-sg"
  }
}

####################################### database Security Group (db_sg) #######################################
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow access to RDS DB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id] # Allow traffic from the app_sg security group
  }

  tags = {
    Name = "db-sg"
  }
}