####################################### Application Load Balancer (ALB) #######################################
# Create an Application Load Balancer (ALB) for the Web App
resource "aws_lb" "web_app_alb" {
  name               = "web-app-alb" # Name of the ALB
  internal           = false         # Set to false for internet-facing ALB
  load_balancer_type = "application" # Type of load balancer (Application Load Balancer)

  subnets         = var.public_subnet_ids # Use the public subnet IDs from variables
  security_groups = [var.web_alb_sg_id]   # Use the security group ID from variables

  tags = {
    Name = "web_app App Load Balancer" # Tag for identifying the ALB
  }
}

####################################### ALB Listener #######################################
# Add a Listener to the ALB to forward HTTP traffic to the Target Group
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web_app_alb.arn # Associate with the ALB's ARN
  port              = 80                     # Set the listener port to 80 (HTTP)
  protocol          = "HTTP"                 # Protocol used by the listener

  default_action {
    type             = "forward"                                    # Forward traffic
    target_group_arn = aws_lb_target_group.web_app_target_group.arn # Forward traffic to the target group
  }
}

####################################### ALB Target Group #######################################
# Create a Target Group for the ALB to route traffic
resource "aws_lb_target_group" "web_app_target_group" {
  name     = "web-app-target-group" # Name of the target group
  port     = 80                     # Port for the target group (80 for HTTP)
  protocol = "HTTP"                 # Protocol used for routing traffic
  vpc_id   = var.vpc_id             # VPC ID for the target group

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
    Name = "web-app App Target Group" # Tag for identifying the target group
  }
}

####################################### Launch Template #######################################
# Launch Template using the dynamically fetched image_id
resource "aws_launch_template" "web_app_launch_template" {
  name_prefix   = "web-app"    # Prefix for the launch template name
  image_id      = var.image_id # Use the dynamically fetched Amazon Linux 2 AMI ID
  instance_type = "t2.micro"   # Instance type for the web app (can be changed as needed)
}

####################################### Auto Scaling Group #######################################
# Auto Scaling Group for the Web App, using the launch template
resource "aws_autoscaling_group" "web_app_asg" {
  availability_zones = var.availability_zones # Use available AZs dynamically fetched
  desired_capacity   = 0                      # Desired number of instances
  max_size           = 0                      # Maximum number of instances
  min_size           = 0                      # Minimum number of instances

  launch_template {
    id      = aws_launch_template.web_app_launch_template.id # Reference the launch template ID
    version = "$Latest"                                      # Use the latest version of the launch template
  }

  # Tag all instances with the same name
  tag {
    key                 = "Name"             # Tag key for the instance's name
    value               = "web-app-instance" # Name of the instances 
    propagate_at_launch = true               # Ensure the tag is applied to instances when they are launched
  }
}
