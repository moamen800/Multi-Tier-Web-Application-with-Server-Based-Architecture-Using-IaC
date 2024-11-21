####################################### AWS Region Variable #######################################
variable "aws_region" {
  description = "AWS region for resource deployment"
}

# ####################################### Web ALB Variable #######################################
variable "web_alb_dns_name" {
  description = "dns of the web_app_alb"
  type        = string
}

variable "web_alb_id" {
  description = "dns of the web_app_alb"
  type        = string
}
