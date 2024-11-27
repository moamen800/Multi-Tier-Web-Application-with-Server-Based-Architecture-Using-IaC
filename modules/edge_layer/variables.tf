####################################### AWS Region Variable #######################################
variable "aws_region" {
  description = "AWS region for resource deployment"
}

variable "presentation_alb_dns_name" {
  description = "DNS of the presentation_alb"
  type        = string
}

variable "presentation_alb_id" {
  description = "ID of the presentation_alb"
  type        = string
}
