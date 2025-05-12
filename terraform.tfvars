# This file contains the variables used in the Terraform configuration.
aws_region    = "eu-west-1"
aws_profile   = "default"
key_name      = "keypair_Ireland"
image_id      = "ami-0df368112825f8d8f"
instance_type = "t3.micro"

# The following variables are specific to the network module
vpc_name = "multi-tier-vpc"
vpc_cidr = "10.0.0.0/16"

public_subnets = {
  "eu-west-1a" = "10.0.1.0/24"
  "eu-west-1b" = "10.0.2.0/24"
}

private_subnets = {
  "eu-west-1a" = "10.0.100.0/24"
  "eu-west-1b" = "10.0.200.0/24"
}

# The following variables are specific to the edge layer module
acm_certificate_arn = "arn:aws:acm:us-east-1:307946672811:certificate/f189a81c-6fce-41fd-bc31-f7b6c5c0c7e8"
domain_name         = "moamenahmed.online"
record_name         = "addperson"
cloudfront_aliases  = ["addperson.moamenahmed.online"]

# The following variables are specific to the database module
db_name     = "mydatabase14121414"
db_username = "Moamen"
db_password = "moamen146"