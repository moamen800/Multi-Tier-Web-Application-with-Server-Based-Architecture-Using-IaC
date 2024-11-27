output "business_logic_alb_dns_name" {
  description = "The DNS of the business_logic_servers_alb"
  value       = aws_lb.business_logic_alb.dns_name
}