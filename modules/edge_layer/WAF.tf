# # WAF Web ACL Configuration
# resource "aws_wafv2_web_acl" "WAF_web_acl" {
#   name        = "WAF-Web-ACL"
#   description = "WAF ACL to protect CloudFront distribution from XSS, and bot traffic."
#   scope       = "CLOUDFRONT" # Scope for CloudFront, as this is a global service.
#   depends_on  = [aws_cloudfront_distribution.cdn]
#   default_action {
#     allow {} # Allow requests by default unless blocked by a rule.
#   }

#   rule {
#     name     = "AllowAllRule"
#     priority = 0
#     action {
#       allow {}
#     }
#     statement {
#       byte_match_statement {
#         search_string = "example"
#         field_to_match {
#           query_string {}
#         }
#         positional_constraint = "CONTAINS"

#         text_transformation {
#           priority = 0
#           type     = "LOWERCASE"
#         }
#       }
#     }
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "allowAllRule"
#       sampled_requests_enabled   = true
#     }
#   }

#   ####################################### Visibility Configuration #######################################
#   visibility_config {
#     cloudwatch_metrics_enabled = true          # Enable CloudWatch metrics for the Web ACL.
#     metric_name                = "WAF-Web-ACL" # Metric name for monitoring the Web ACL's performance.
#     sampled_requests_enabled   = true          # Enable request sampling for analysis.
#   }
# }




#   # ####################################### Managed Rule Groups #######################################
#   # These managed rule groups provide protection against common threats.

#   # Cross-Site Scripting (XSS) Protection
#   rule {
#     name     = "AWS-AWSManagedRulesXSSRuleSet"
#     priority = 1  # This rule is evaluated after SQL injection protection.

#     statement {
#       managed_rule_group_statement {
#         vendor_name = "AWS"
#         name        = "AWSManagedRulesXSSRuleSet"  # Protects against XSS attacks.
#       }
#     }

#     override_action {
#       none {}  # Do not override the default action; use the managed rule group's default behavior.
#     }

#     visibility_config {
#       sampled_requests_enabled   = true        # Enable request sampling for analysis.
#       cloudwatch_metrics_enabled = true        # Enable CloudWatch metrics.
#       metric_name                = "XSSRuleSet"  # CloudWatch metric name for XSS.
#     }
#   }

#   # Bot Controls
#   rule {
#     name     = "AWS-AWSManagedRulesBotControlRuleSet"
#     priority = 2  # This rule is evaluated after XSS protection.

#     statement {
#       managed_rule_group_statement {
#         vendor_name = "AWS"
#         name        = "AWSManagedRulesBotControlRuleSet"  # Protects against bot traffic.
#       }
#     }

#     override_action {
#       none {}  # Do not override the default action; use the managed rule group's default behavior.
#     }

#     visibility_config {
#       sampled_requests_enabled   = true                # Enable request sampling for analysis.
#       cloudwatch_metrics_enabled = true                # Enable CloudWatch metrics.
#       metric_name                = "BotControlRuleSet"  # CloudWatch metric name for bot control.
#     }
#   }
