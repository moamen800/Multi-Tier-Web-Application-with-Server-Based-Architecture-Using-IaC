output "business_logic_alb_dns_name" {
  description = "The DNS of the business_logic_servers_alb"
  value       = aws_lb.business_logic_alb.dns_name
}
output "business_logic_alb_id" {
  description = "The ID of the business logic ALB"
  value       = aws_lb.business_logic_alb.id
}

output "business_logic_alb_zone_id" {
  description = "Hosted Zone ID of the Business Logic Application Load Balancer"
  value       = aws_lb.business_logic_alb.zone_id
}
