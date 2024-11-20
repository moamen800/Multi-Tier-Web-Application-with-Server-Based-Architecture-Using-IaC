####################################### S3 Bucket Name Variable #######################################
variable "s3_bucket_name" {
  description = "S3 bucket name for the frontend"
  type        = string
  default     = "frontendbucket14444444444441"
}

####################################### AWS Region Variable #######################################
variable "aws_region" {
  description = "AWS region for resource deployment"
}

####################################### CloudFront Variable #######################################
variable "web_app_alb_dns_name" {
  description = "dns of the web_app_alb"
  type        = string
}

####################################### WAF Variable #######################################
variable "web_app_alb_id" {
  description = "dns of the web_app_alb"
  type        = string
}


####################################### Cognito Variable #######################################
# Variables for Google OAuth credentials.
# variable "google_client_id" {
#   description = "Google OAuth Client ID."
#   type        = string
# }

# variable "google_client_secret" {
#   description = "Google OAuth Client Secret."
#   type        = string
# }

# # Variables for Facebook OAuth credentials.
# variable "facebook_app_id" {
#   description = "Facebook App ID for OAuth integration."
#   type        = string
# }

# variable "facebook_app_secret" {
#   description = "Facebook App Secret for OAuth integration."
#   type        = string
# }
