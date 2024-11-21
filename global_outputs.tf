output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.edge_layer.cloudfront_domain_name

}

output "web_alb_dns_name" {
  description = "The DNS of the web_app_alb"
  value       = module.web_app.web_alb_dns_name
}

output "app_alb_dns_name" {
  description = "The DNS of the app_servers_alb"
  value       = module.application_servers.app_alb_dns_name
}

