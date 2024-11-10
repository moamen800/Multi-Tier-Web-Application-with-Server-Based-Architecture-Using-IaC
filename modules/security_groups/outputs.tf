####################################### Security Group Outputs #######################################

# Output the ID of the web application load balancer security group (web_alb_sg)
output "web_alb_sg_id" {
  description = "ID of the web application load balancer security group"
  value       = aws_security_group.web_alb_sg.id # Reference the ID of the ALB security group
}

# Output the ID of the web security group for instances (web_sg)
output "web_sg_id" {
  description = "The ID of the web security group for instances"
  value       = aws_security_group.web_sg.id # Reference the ID of the web instance security group
}

# Output the ID of the app application load balancer security group (app_alb_sg)
output "app_alb_sg_id" {
  description = "ID of the web application load balancer security group"
  value       = aws_security_group.app_alb_sg.id # Reference the ID of the ALB security group
}

# Output the ID of the web security group for instances (app_sg)
output "app_sg_id" {
  description = "The ID of the web security group for instances"
  value       = aws_security_group.app_sg.id # Reference the ID of the web instance security group
}
