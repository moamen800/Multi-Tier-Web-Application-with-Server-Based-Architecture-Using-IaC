output "web_app_alb_dns_name" {
  description = "dns of the web_app_alb"
  value = aws_lb.web_app_alb.dns_name
}

output "web_app_alb_id" {
  description = "dns of the web_app_alb"
  value = aws_lb.web_app_alb.id
}