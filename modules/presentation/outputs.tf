output "presentation_alb_dns_name" {
  description = "dns of the presentation_alb"
  value       = aws_lb.presentation_alb.dns_name
}

output "presentation_alb_id" {
  description = "The DNS of the presentation_alb"
  value       = aws_lb.presentation_alb.id
}