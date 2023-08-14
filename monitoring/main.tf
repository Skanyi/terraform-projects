################################################################################
# Managed Grafana Module
################################################################################

module "managed_grafana" {
  source = "./modules/grafana"

  main-region = var.main-region
  profile     = var.profile
  env_name    = var.env_name

  private_subnets = var.private_subnets
  sso_admin_group_id = var.sso_admin_group_id
}



################################################################################
# Managed Prometheus Module
################################################################################

module "prometheus" {
  source = "./modules/prometheus"

  main-region = var.main-region
  profile     = var.profile
  env_name    = var.env_name

  cluster_name      = var.cluster_name
  oidc_provider_arn = var.oidc_provider_arn
  vpc_id            = var.vpc_id
  private_subnets   = var.private_subnets
}



################################################################################
# VPC Endpoints for Prometheus and Grafana Module
################################################################################

module "vpcendpoints" {
  source = "./modules/vpcendpoints"

  main-region = var.main-region
  profile     = var.profile
  env_name    = var.env_name

  vpc_id                    = var.vpc_id
  private_subnets           = var.private_subnets
  grafana_security_group_id = module.managed_grafana.security_group_id
}




