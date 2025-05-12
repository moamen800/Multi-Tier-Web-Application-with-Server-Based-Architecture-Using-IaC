provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "presentation_alb_dns_name" {
  description = "DNS of the presentation_alb"
  type        = string
}

variable "presentation_alb_id" {
  description = "ID of the presentation_alb"
  type        = string
}

variable "business_logic_alb_dns_name" {
  description = "The DNS name of the business logic ALB (port 3000)"
  type        = string
}

variable "business_logic_alb_id" {
  description = "The unique identifier of the business logic ALB"
  type        = string
}

variable "business_logic_alb_zone_id" {
  description = "The Hosted Zone ID for the Business Logic ALB"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate in us-east-1 (required for CloudFront)"
  type        = string
}

variable "domain_name" {
  description = "The domain name to use for the CloudFront distribution"
  type        = string
}
variable "backend_subdomain" {
  description = "Subdomain name for backend ALB"
  type        = string
  default     = "backend"
}

variable "record_name" {
  description = "The name of the record to create in Route 53"
  type        = string
}

variable "cloudfront_aliases" {
  description = "List of alternate domain names (CNAMEs) for CloudFront distribution"
  type        = list(string)
}