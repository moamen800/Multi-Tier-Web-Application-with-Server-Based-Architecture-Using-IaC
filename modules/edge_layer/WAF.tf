# ####################################### WAF Web ACL Configuration #######################################
# # This Web ACL protects your CloudFront distribution from XSS, and bot traffic.
# resource "aws_wafv2_web_acl" "WAF_web_acl" {
#   name        = "WAF-Web-ACL"
#   description = "WAF ACL to protect CloudFront distribution from XSS, and bot traffic."
#   scope       = "CLOUDFRONT" # Global scope for CloudFront distribution, as this is used globally.


#   default_action {
#     allow {} # Allow requests by default unless blocked by a rule.
#   }

#   # ####################################### Managed Rule Groups #######################################
#   # These managed rule groups provide protection against common threats.

#   # Cross-Site Scripting (XSS) Protection
#   rule {
#     name     = "AWS-AWSManagedRulesXSSRuleSet"
#     priority = 1 # This rule is evaluated after SQL injection protection.

#     statement {
#       managed_rule_group_statement {
#         vendor_name = "AWS"
#         name        = "AWSManagedRulesXSSRuleSet" # This managed rule group protects against Cross-Site Scripting (XSS) attacks, which could allow attackers to inject malicious scripts into a trusted website, potentially harming site users.
#       }
#     }

#     override_action {
#       none {} # Follow the default action specified in the AWS managed rule set.
#     }

#     visibility_config {
#       sampled_requests_enabled   = true         # Enables sampling of requests that match this rule for further analysis.
#       cloudwatch_metrics_enabled = true         # Enables CloudWatch metrics to monitor and measure the rule's effectiveness.
#       metric_name                = "XSSRuleSet" # Metric name for CloudWatch logging.
#     }
#   }

#   # Bot Controls
#   rule {
#     name     = "AWS-AWSManagedRulesBotControlRuleSet"
#     priority = 2 # This rule is evaluated after SQL injection and XSS protection.

#     statement {
#       managed_rule_group_statement {
#         vendor_name = "AWS"
#         name        = "AWSManagedRulesBotControlRuleSet" # This managed rule group helps block unwanted bot traffic, which can disrupt services by overwhelming resources or scraping sensitive information.
#       }
#     }

#     override_action {
#       none {} # Follow the default action specified in the AWS managed rule set.
#     }

#     visibility_config {
#       sampled_requests_enabled   = true                # Enables sampling of requests that match this rule for additional analysis.
#       cloudwatch_metrics_enabled = true                # Enables CloudWatch metrics for continuous monitoring of rule effectiveness.
#       metric_name                = "BotControlRuleSet" # Metric name for CloudWatch logging.
#     }
#   }

#   ####################################### Visibility Configuration #######################################
#   # Configures logging and metrics to monitor the overall effectiveness of the WAF Web ACL.
#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "WAF-Web-ACL" # Overall Web ACL metric name for monitoring.
#     sampled_requests_enabled   = true
#   }
# }