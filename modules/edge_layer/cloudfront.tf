####################################### Origin Access Control (OAC) #######################################
# Defines the Origin Access Control for securing access to the S3 bucket
# through CloudFront. It ensures that all requests to the S3 origin are signed using 
# AWS SigV4 signing protocol for enhanced security.

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "OAC-for-S3-${var.s3_bucket_name}"                              # Name for the Origin Access Control, using the S3 bucket ID for uniqueness
  origin_access_control_origin_type = "s3"                                                            # Specifies that the origin is an S3 bucket
  signing_behavior                  = "always"                                                        # Ensures that all requests to the S3 origin are signed by CloudFront
  signing_protocol                  = "sigv4"                                                         # Uses the AWS SigV4 signing protocol, required for signed requests to S3
  description                       = "Origin Access Control for S3 bucket access through CloudFront" # Description for this OAC configuration
}

####################################### CloudFront Distribution #######################################
resource "aws_cloudfront_distribution" "cdn" {
  enabled = true # Enable to accept end user requests for content.

  # First origin: S3 for static content
  origin {
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name # S3 origin
    origin_id                = "S3-${aws_s3_bucket.frontend_bucket.id}"                    # Unique origin ID
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id               # Attach OAC for secure access
  }

  # Second origin: ALB for dynamic content
  origin {
    domain_name              = var.web_app_alb_dns_name # ALB DNS name as origin
    origin_id                = "ALB-${var.web_app_alb_id}" # Unique origin ID
    custom_origin_config {
      http_port  = 80        # ALB HTTP port
      https_port = 443       # Optional: if you configure SSL for ALB
      origin_protocol_policy = "match-viewer" # Allow both HTTP and HTTPS traffic
      origin_ssl_protocols  = ["TLSv1.2"]  # Set valid SSL protocols for HTTPS traffic
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]                            # Allow GET and HEAD methods
    cached_methods         = ["GET", "HEAD"]                            # Only allow caching of GET and HEAD methods
    target_origin_id       = "S3-${aws_s3_bucket.frontend_bucket.id}"   # Reference the S3 origin
    viewer_protocol_policy = "redirect-to-https"                        # Enforce HTTPS for security

    min_ttl     = 0      # Minimum cache TTL (0 seconds)
    default_ttl = 3600   # Default TTL (1 hour)
    max_ttl     = 86400  # Maximum TTL (1 day)
    compress    = true   # Enable automatic compression of objects

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Amazon's Managed Cache Policy: CachingOptimized
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Amazon's Managed Origin Request Policy: AllViewer
  }

  # Cache behavior for dynamic content served from ALB
  ordered_cache_behavior {
    path_pattern              = "/api/*"                                      #  Pattern (for example, images/*.jpg) that specifies which requests you want this cache behavior to apply to.
    target_origin_id          = "ALB-${var.web_app_alb_id}"                   #  Value of ID for the origin that you want CloudFront to route requests to when a request matches the path pattern either for a cache behavior or for the default cache behavior.
    viewer_protocol_policy    = "allow-all"                                   # Allow all protocols
    cache_policy_id           = "658327ea-f89d-4fab-a63d-7e88639e58f6"        # Managed cache policy
    origin_request_policy_id  = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"        # Managed origin request policy
    cached_methods            = ["GET", "HEAD", "OPTIONS"]  # Only allow caching for GET, HEAD, and OPTIONS methods
    allowed_methods           = ["GET", "HEAD", "POST", "PUT", "OPTIONS", "PATCH", "DELETE"]  # Allowed HTTP methods for dynamic content
  }

  restrictions {
    geo_restriction {
      restriction_type = "none" # No geographic restrictions
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # Use CloudFront's default SSL certificate
  }

  # Attach WAF Web ACL
  web_acl_id = aws_wafv2_web_acl.WAF_web_acl.arn # Attach the WAF Web ACL
}
