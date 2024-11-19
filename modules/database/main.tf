####################################### RDS Database Instance #######################################
# RDS Database Instance resource for PostgreSQL
resource "aws_db_instance" "rds-db" {
  allocated_storage    = 5                    # Database storage in GB
  db_name              = var.db_name          # Name of the database
  engine               = "postgres"           # Database engine type (PostgreSQL)
  engine_version       = "12.20"              # Updated version of PostgreSQL engine
  instance_class       = "db.t3.micro"        # Instance class (db.t2.micro for small instances)
  username             = var.db_username      # Database username
  password             = var.db_password      # Database password
  storage_type         = "gp2"                # General Purpose SSD storage type
  parameter_group_name = "default.postgres12" # Default PostgreSQL parameter group for version 12
  skip_final_snapshot  = true                 # Skips final snapshot before deletion of the DB instance
  multi_az             = true                 # Multi-AZ deployment for high availability
  publicly_accessible  = false                # Prevent public access to the DB instance (internal only)
  tags = {
    Name = "RDS-Database" # Tag for identifying this specific RDS instance
  }
  vpc_security_group_ids = [var.db_sg_id]                        # Reference to the DB security group for controlling access
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name # DB subnet group for placing the RDS instance in private subnets
}


####################################### Custom Subnet Group for RDS #######################################
# Custom subnet group for placing the RDS instance in specific subnets
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "db-subnet-group"      # Name for the custom DB subnet group
  subnet_ids  = var.private_subnet_ids # List of private subnet IDs where the RDS instance will be placed
  description = "RDS Subnet Group"     # Description for the subnet group
  tags = {
    name = "db_subnet_group"
  }
}
