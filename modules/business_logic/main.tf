####################################### Application Load Balancer (ALB) #######################################
# Create an Application Load Balancer (ALB) for the business_logic
resource "aws_lb" "business_logic_alb" {
  name               = "business-logic-alb"           # Name of the ALB
  internal           = false                          # Set to false for internet-facing ALB
  load_balancer_type = "application"                  # Type of load balancer (Application Load Balancer)
  subnets            = var.public_subnet_ids          # Use the public subnet IDs from variables
  security_groups    = [var.business_logic_alb_sg_id] # Use the security group ID from variables

  tags = {
    Name = "Internal App Load Balancer" # Tag for identifying the ALB
  }
}

####################################### ALB Listener #######################################
# Add a Listener to the ALB to forward HTTP traffic to the Target Group
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.business_logic_alb.arn # Associate with the ALB's ARN
  port              = 3000                          # Set the listener port to 3000 (
  protocol          = "HTTP"                        # Protocol used by the listener

  default_action {
    type             = "forward"                                           # Forward traffic
    target_group_arn = aws_lb_target_group.business_logic_target_group.arn # Forward traffic to the target group
  }
}

####################################### ALB Target Group #######################################
# Create a Target Group for the ALB to route traffic
resource "aws_lb_target_group" "business_logic_target_group" {
  name     = "business-logic-target-group" # Name of the target group
  port     = 3000                          # Port for the target group
  protocol = "HTTP"                        # Protocol used for routing traffic
  vpc_id   = var.vpc_id                    # VPC ID for the target group

  # Health check configuration for the target group
  health_check {
    interval            = 30               # Time between health checks (in seconds)
    path                = "/api/v1/people" # Path used to check the health of the targets
    protocol            = "HTTP"           # Protocol for the health check
    timeout             = 5                # Timeout for health checks (in seconds)
    healthy_threshold   = 2                # Number of successful health checks required to consider the target healthy
    unhealthy_threshold = 2                # Number of failed health checks required to consider the target unhealthy
  }

  tags = {
    Name = "business logic Target Group" # Tag for identifying the target group
  }
}

####################################### Launch Template #######################################
# Launch Template using the dynamically fetched image_id
resource "aws_launch_template" "business_logic_launch_template" {
  name_prefix            = "business-logic-launch-template" # Prefix for the launch template name
  image_id               = var.image_id                     # Use the dynamically fetched Amazon Linux 2 AMI ID
  vpc_security_group_ids = [var.business_logic_sg_id]       # Security group for instances launched from this template
  instance_type          = var.instance_type                # Instance type for the presentation business_logic (can be changed as needed)
  key_name               = var.key_name                     # Replace with your key pair name
  user_data              = filebase64(("${path.module}/backend.sh"))
  iam_instance_profile {
    name = aws_iam_instance_profile.business_logic_instance_profile.name
  }
}

####################################### Auto Scaling Group #######################################
# Auto Scaling Group for the Web App, using the launch template
resource "aws_autoscaling_group" "business_logic_asg" {
  name                = "business_logics_asg"
  desired_capacity    = 2 # Desired number of instances
  max_size            = 2 # Maximum number of instances
  min_size            = 1 # Minimum number of instances
  health_check_type   = "EC2"
  vpc_zone_identifier = var.private_subnets_ids                               # Use available AZs dynamically fetched
  target_group_arns   = [aws_lb_target_group.business_logic_target_group.arn] # Add the target group ARN
  depends_on          = [aws_lb.business_logic_alb]
  launch_template {
    id      = aws_launch_template.business_logic_launch_template.id # Reference the launch template ID
    version = "$Latest"                                             # Use the latest version of the launch template
  }

  # Tag all instances with the same name
  tag {
    key                 = "Name"                    # Tag key for the instance's name
    value               = "business-logic-instance" # Name of the instances 
    propagate_at_launch = true                      # Ensure the tag is business_logiclied to instances when they are launched
  }
  tag {
    key                 = "Title"
    value               = "prometheus"
    propagate_at_launch = true
  }
}


####################################### IAM Roles and Policies #######################################

# IAM Role for EC2 instances
resource "aws_iam_role" "business_logic_role" {
  name = "business-logic-role"

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
resource "aws_iam_role_policy_attachment" "business_logic_role_policy" {
  role       = aws_iam_role.business_logic_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDocDBReadOnlyAccess"
}


# IAM Instance Profile
resource "aws_iam_instance_profile" "business_logic_instance_profile" {
  name = "business-logic-instance-profile"
  role = aws_iam_role.business_logic_role.name
}
