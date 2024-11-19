####################################### ALB Security Group (web_alb_sg) #######################################
resource "aws_security_group" "web_alb_sg" {
  name   = "web_alb_sg"
  vpc_id = var.vpc_id

  # HTTP Ingress (Port 80) – Allow incoming HTTP traffic to the ALB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule – Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 allows all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-alb-sg"
  }
}

####################################### Web Security Group (web_sg) #######################################
resource "aws_security_group" "web_sg" {
  name   = "web_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.web_alb_sg.id]
  }

  # Allow SSH (Port 22) – Use with caution, allows SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule – Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 allows all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

####################################### ALB Security Group (app_alb_sg) #######################################
resource "aws_security_group" "app_alb_sg" {
  name   = "app-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = [aws_security_group.web_sg.id]
  }

  # Outbound rule – Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 allows all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-alb-sg"
  }
}

####################################### app Security Group (app_sg) #######################################
resource "aws_security_group" "app_sg" {
  name   = "app-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.app_alb_sg.id]
    
  }

  # Allow SSH (Port 22) – Use with caution, allows SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule – Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 allows all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}

####################################### database Security Group (db_sg) #######################################
# resource "aws_security_group" "db_sg" {
#   name        = "db-sg"
#   description = "Allow access to RDS DB"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     # security_groups = [aws_security_group.app_sg.id]
#   }

#   # Outbound rule – Allow all outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1" # -1 allows all traffic
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "db-sg"
#   }
# }
