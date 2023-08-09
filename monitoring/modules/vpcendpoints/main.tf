################################################################################
# Prometheus VPC Endpoint Security group
################################################################################

resource "aws_security_group" "allow_tls_grafana" {
  name        = "allow_tls_from_grafana"
  description = "Allow TLS inbound traffic from Grafana"
  vpc_id      = var.vpc_id
  provider    = aws.us-east-2
  ingress {
    description     = "TLS from Grafana Security group"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.grafana_security_group_id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "allow_tls_grafana"
    Terraform   = "true"
    Environment = var.env_name
  }
}

################################################################################
# Prometheus VPC Endpoint
################################################################################

resource "aws_vpc_endpoint" "prometheus" {
  vpc_id            = var.vpc_id
  provider          = aws.us-east-2
  service_name      = "com.amazonaws.us-east-2.aps-workspaces"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.allow_tls_grafana.id,
  ]

  #private_dns_enabled = true
  subnet_ids = var.private_subnets
}

