output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "web_app_alb_dns_name" {
  description = "The DNS of the web_app_alb"
  value       = module.web_app.web_app_alb_dns_name
}

output "app_servers_dns_name" {
  description = "The DNS of the app_servers_alb"
  value       = module.application_servers.app_servers_dns_name
}