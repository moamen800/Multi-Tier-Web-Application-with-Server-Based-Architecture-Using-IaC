variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "db_sg_id" {
  description = "The ID of the web security group for instances"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "mydatabase"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  default     = "admin#2002#"
  sensitive   = true
}
