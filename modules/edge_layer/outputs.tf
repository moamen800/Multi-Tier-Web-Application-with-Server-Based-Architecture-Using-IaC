####################################### CloudFront Distribution Output #######################################
# Outputs to provide key details for the CloudFront distribution and WAF Web ACL association.
output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.cdn.domain_name
  description = "The domain name of the CloudFront distribution"
}

output "cloudfront_distribution_arn" {
  value       = aws_cloudfront_distribution.cdn.arn
  description = "The ARN of the CloudFront distribution"
}
##############################################  WAF Output  ##############################################
output "waf_web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.WAF_web_acl.arn # Retrieves the ARN for reference or for connecting other resources
}


#############################################  Cognito Output  #############################################
# output "user_pool_id" {
#   description = "The ID of the Cognito User Pool"
#   value       = aws_cognito_user_pool.user_pool.id
# }

# output "user_pool_client_id" {
#   description = "The ID of the Cognito User Pool Client"
#   value       = aws_cognito_user_pool_client.user_pool_client.id
# }

# output "identity_pool_id" {
#   description = "The ID of the Cognito Identity Pool"
#   value       = aws_cognito_identity_pool.identity_pool.id
# }


