####################################### CloudFront Distribution #######################################
resource "aws_cloudfront_distribution" "cdn" {
  enabled = true # Enable CloudFront distribution to accept end-user requests

  # Origin: ALB for dynamic content
  origin {
    domain_name = var.web_alb_dns_name    # ALB DNS name as origin
    origin_id   = "ALB-${var.web_alb_id}" # Unique origin ID
    custom_origin_config {
      http_port              = 80             # ALB HTTP port
      https_port             = 443            # Optional: if you configure SSL for ALB
      origin_protocol_policy = "match-viewer" # Allow both HTTP and HTTPS traffic based on viewer's protocol
      origin_ssl_protocols   = ["TLSv1.2"]    # Set valid SSL protocols for HTTPS traffic
    }
  }

  # Default cache behavior: Handling of content by CloudFront 
  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "POST", "PUT", "OPTIONS", "PATCH", "DELETE"] # Allow all necessary methods
    cached_methods           = ["GET", "HEAD", "OPTIONS"]                                   # Cache only the essential methods
    target_origin_id         = "ALB-${var.web_alb_id}"                                      # Reference the ALB origin
    viewer_protocol_policy   = "allow-all"                                                  # Allow both HTTP and HTTPS traffic
    min_ttl                  = 60                                                           # Minimum cache TTL (1 minute)
    default_ttl              = 600                                                          # Default TTL (10 minutes)
    max_ttl                  = 900                                                          # Maximum TTL (15 minutes)
    compress                 = true                                                         # Enable automatic compression of objects
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"                       # Managed Cache Policy for optimized caching
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"                       # Managed Origin Request Policy
  }

  # Geo restriction: no restrictions (open globally)
  restrictions {
    geo_restriction {
      restriction_type = "whitelist" # Allow only countries in the locations list
      locations        = ["EG"]      # Country code for Egypt
    }
  }

  # CloudFront Viewer Certificate (SSL for HTTPS traffic)
  viewer_certificate {
    cloudfront_default_certificate = true # Use CloudFront's default SSL certificate for HTTPS traffic
  }

  # Optional: Attach WAF Web ACL for additional security
  # web_acl_id = aws_wafv2_web_acl.WAF_web_acl.arn # Attach the WAF Web ACL
}


# ####################################### Origin Access Control (OAC) #######################################
# # Defines the Origin Access Control for securing access to the S3 bucket
# # through CloudFront. It ensures that all requests to the S3 origin are signed using 
# # AWS SigV4 signing protocol for enhanced security.

# # resource "aws_cloudfront_origin_access_control" "oac" {
# #   name                              = "OAC-for-S3-${var.s3_bucket_name}"                              # Name for the Origin Access Control
# #   origin_access_control_origin_type = "s3"                                                            # Specifies that the origin is an S3 bucket
# #   signing_behavior                  = "always"                                                        # Ensures requests to S3 are signed
# #   signing_protocol                  = "sigv4"                                                         # Uses SigV4 for signing requests to S3
# #   description                       = "Origin Access Control for S3 bucket access through CloudFront" # Description for the OAC configuration
# # }
