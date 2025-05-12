####################################### Route 53  #######################################
# resource "aws_route53_zone" "main" {
#   name    = var.domain_name
#   comment = "Hosted zone for moamenahmed.online integrated with CloudFront"
# }

# resource "aws_route53_record" "cloudfront_domain_record" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = var.record_name
#   type    = "A"
#   alias {
#     name                   = aws_cloudfront_distribution.cdn.domain_name
#     zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_record" "backend_domain_record" {
#   zone_id = aws_route53_zone.main.zone_id
#   name = "${var.backend_subdomain}.${var.domain_name}"
#   type    = "A"

#   alias {
#     name                   = var.business_logic_alb_dns_name
#     zone_id                = var.business_logic_alb_zone_id
#     evaluate_target_health = true
#   }
# }


####################################### CloudFront Distribution #######################################
resource "aws_cloudfront_distribution" "cdn" {
  enabled = true
  # aliases = var.cloudfront_aliases

  # Origin: Presentation Layer ALB
  origin {
    domain_name = var.presentation_alb_dns_name
    origin_id   = "ALB-${var.presentation_alb_id}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default Cache Behavior: presentation layer
  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "POST", "PUT", "OPTIONS", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    target_origin_id         = "ALB-${var.presentation_alb_id}"
    viewer_protocol_policy   = "allow-all"
    min_ttl                  = 60
    default_ttl              = 600
    max_ttl                  = 900
    compress                 = true
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["EG"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  web_acl_id = aws_wafv2_web_acl.WAF_presentation_acl.arn
}

######################################## WAF Web ACL #######################################
resource "aws_wafv2_web_acl" "WAF_presentation_acl" {
  name        = "WAF-Presentation-ACL"
  description = "Blocks IPs from Egypt exceeding 500 requests in 5 minutes"
  scope       = "CLOUDFRONT"
  provider    = aws.us_east_1

  default_action {
    allow {}
  }

  rule {
    name     = "RateBasedRule-Egypt"
    priority = 1

    action {
      block {
        custom_response {
          response_code = 403
        }
      }
    }

    statement {
      rate_based_statement {
        limit              = 500
        aggregate_key_type = "IP"

        scope_down_statement {
          geo_match_statement {
            country_codes = ["EG"]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateBasedRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-CommonRuleSet"
    priority = 2

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAFPresentationACLMetric"
    sampled_requests_enabled   = true
  }
}
