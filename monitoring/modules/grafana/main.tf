module "managed_grafana" {
  source = "terraform-aws-modules/managed-service-grafana/aws"

  providers = {
    aws = aws.us-east-2
  }

  # Workspace
  name                      = "eks-grafana"
  description               = "AWS Managed Grafana service"
  account_access_type       = "CURRENT_ACCOUNT"
  authentication_providers  = ["AWS_SSO"]
  permission_type           = "SERVICE_MANAGED"
  data_sources              = ["CLOUDWATCH", "PROMETHEUS", "XRAY"]
  notification_destinations = ["SNS"]

  create_workspace      = true
  create_iam_role       = true
  create_security_group = true
  associate_license     = false
  license_type          = "ENTERPRISE_FREE_TRIAL"
  vpc_configuration = {
    subnet_ids = var.private_subnets
  }

  security_group_rules = {
    egress = {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  # Workspace API keys
  workspace_api_keys = {
    viewer = {
      key_name        = "viewer"
      key_role        = "VIEWER"
      seconds_to_live = 3600
    }
    editor = {
      key_name        = "editor"
      key_role        = "EDITOR"
      seconds_to_live = 3600
    }
    admin = {
      key_name        = "admin"
      key_role        = "ADMIN"
      seconds_to_live = 3600
    }
  }


  # Role associations
  role_associations = {
    "ADMIN" = {
      "group_ids" = ["72a55424-40d1-701f-6bdf-2c4227265d17"]
    }
  }

  tags = {
    Terraform   = "true"
    Environment = var.env_name
  }
}
