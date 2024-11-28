####################################### Application Load Balancer (ALB) #######################################
# Create an Application Load Balancer (ALB) for the Web App
resource "aws_lb" "presentation_alb" {
  name               = "presentation-alb"           # Name of the ALB
  internal           = false                        # Set to false for internet-facing ALB
  load_balancer_type = "application"                # Type of load balancer (Application Load Balancer)
  subnets            = var.public_subnet_ids        # Use the public subnet IDs from variables
  security_groups    = [var.presentation_alb_sg_id] # Use the security group ID from variables

  tags = {
    Name = "Internet-Facing App Load Balancer" # Tag for identifying the ALB
  }
}

####################################### ALB Listener #######################################

# Add a Listener to the ALB to forward HTTP traffic to the Target Group
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.presentation_alb.arn # Associate with the ALB's ARN
  port              = 80                          # Set the listener port to 80 (HTTP)
  protocol          = "HTTP"                      # Protocol used by the listener

  default_action {
    type             = "forward"                                         # Forward traffic
    target_group_arn = aws_lb_target_group.presentation_target_group.arn # Forward traffic to the target group
  }
}

####################################### ALB Target Group #######################################

# Create a Target Group for the ALB to route traffic
resource "aws_lb_target_group" "presentation_target_group" {
  name     = "presentation-target-group" # Name of the target group
  port     = 80                          # Port for the target group (80 for HTTP)
  protocol = "HTTP"                      # Protocol used for routing traffic
  vpc_id   = var.vpc_id                  # VPC ID for the target group

  # Health check configuration for the target group
  health_check {
    interval            = 30     # Time between health checks (in seconds)
    path                = "/"    # Path used to check the health of the targets
    protocol            = "HTTP" # Protocol for the health check
    timeout             = 5      # Timeout for health checks (in seconds)
    healthy_threshold   = 2      # Number of successful health checks required to consider the target healthy
    unhealthy_threshold = 2      # Number of failed health checks required to consider the target unhealthy
  }

  tags = {
    Name = "presentation-app App Target Group" # Tag for identifying the target group
  }
}

####################################### Launch Template #######################################

# Launch Template using the dynamically fetched image_id
resource "aws_launch_template" "presentation_launch_template" {
  name_prefix            = "presentation-launch-template" # Prefix for the launch template name
  image_id               = var.image_id                   # Use the dynamically fetched Amazon Linux 2 AMI ID
  vpc_security_group_ids = [var.presentation_sg_id]       # Security group for instances launched from this template
  instance_type          = "t2.micro"                     # Instance type for the presentation app (can be changed as needed)
  key_name               = "keypair"                      # Replace with your key pair name 
  user_data              = filebase64(("${path.module}/frontend.sh"))
  iam_instance_profile {
    name = aws_iam_instance_profile.presentation_instance_profile.name
  }
}

####################################### Auto Scaling Group #######################################

# Auto Scaling Group for the Web App, using the launch template
resource "aws_autoscaling_group" "presentation_asg" {
  name                = "presentation_asg"
  desired_capacity    = 1 # Desired number of instances
  max_size            = 2 # Maximum number of instances
  min_size            = 1 # Minimum number of instances
  health_check_type   = "EC2"
  vpc_zone_identifier = var.public_subnet_ids                               # Use available AZs dynamically fetched 
  target_group_arns   = [aws_lb_target_group.presentation_target_group.arn] # Add the target group ARN
  depends_on = [aws_lb.presentation_alb]
  launch_template {
    id      = aws_launch_template.presentation_launch_template.id # Reference the launch template ID
    version = "$Latest"                                           # Use the latest version of the launch template
  }

  # Tag all instances with the same name
  tag {
    key                 = "Name"                  # Tag key for the instance's name
    value               = "presentation-instance" # Name of the instances 
    propagate_at_launch = true                    # Ensure the tag is applied to instances when they are launched
  }
}

####################################### IAM Roles and Policies #######################################

# IAM Role for EC2 instances
resource "aws_iam_role" "presentation_role" {
  name = "presentation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach IAM policy to the role
resource "aws_iam_role_policy_attachment" "presentation_role_policy" {
  role       = aws_iam_role.presentation_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "presentation_instance_profile" {
  name = "presentation-instance-profile"
  role = aws_iam_role.presentation_role.name
}
