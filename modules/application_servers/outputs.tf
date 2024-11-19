output "app_servers_dns_name" {
  description = "The DNS of the app_servers_alb"
  value       = aws_lb.app_servers_alb.dns_name
}