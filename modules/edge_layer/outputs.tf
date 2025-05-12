output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

# output "route53_name_servers" {
#   description = "Name servers to set on your GoDaddy domain"
#   value       = aws_route53_zone.main.name_servers
# }

# output "route53_record_fqdn" {
#   description = "The fully qualified domain name (FQDN) of the record"
#   value       = aws_route53_record.cloudfront_domain_record.fqdn
# }
