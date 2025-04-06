# -------------------------------------------------
# EC2 Instances for monitoring
# -------------------------------------------------
resource "aws_instance" "monitoring" {
  ami                    = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.Monitoring_sg_id]
  user_data              = file("${path.module}/scripts/install-PrometheusServer-Grafana.sh")
  iam_instance_profile   = aws_iam_instance_profile.prometheus_instance_profile.name

  root_block_device {
    volume_size = 10
    volume_type = "gp2" 
  }

  tags = {
    Name  = "Prometheus-Grafana Server"
  }
}

# -------------------------------------------------
# IAM Role for Prometheus Server (Read-Only Access)
# -------------------------------------------------
resource "aws_iam_role" "prometheus_readonly_role" {
  name = "prometheus-readonly-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# ------------------------------------------
# Attach Read-Only Access Policy to IAM Role
# ------------------------------------------
resource "aws_iam_role_policy_attachment" "prometheus_readonly_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  role       = aws_iam_role.prometheus_readonly_role.name
}

# -----------------------------------------------------
# Attach CloudWatch Read-Only Access Policy to IAM Role
# -----------------------------------------------------
resource "aws_iam_role_policy_attachment" "prometheus_cloudwatch_readonly_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  role       = aws_iam_role.prometheus_readonly_role.name
}


# ------------------------------------------
# IAM Instance Profile for Prometheus Server
# ------------------------------------------
resource "aws_iam_instance_profile" "prometheus_instance_profile" {
  name = "prometheus-instance-profile"
  role = aws_iam_role.prometheus_readonly_role.name
}
