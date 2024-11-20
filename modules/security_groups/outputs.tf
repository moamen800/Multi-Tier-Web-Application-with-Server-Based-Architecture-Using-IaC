####################################### Security Group Outputs #######################################
output "web_alb_sg_id" {
  description = "ID of the web application load balancer security group"
  value       = aws_security_group.web_alb_sg.id
}

output "web_sg_id" {
  description = "The ID of the web security group for instances"
  value       = aws_security_group.web_sg.id
}

output "app_alb_sg_id" {
  description = "ID of the web application load balancer security group"
  value       = aws_security_group.app_alb_sg.id
}

output "app_sg_id" {
  description = "The ID of the web security group for instances"
  value       = aws_security_group.app_sg.id
}

output "MongoDB_sg_id" {
  description = "The ID of the web security group for instances"
  value       = aws_security_group.MongoDB_sg.id
}
