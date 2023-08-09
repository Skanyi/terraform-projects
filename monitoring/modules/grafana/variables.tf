################################################################################
# General Variables from root module
################################################################################

variable "profile" {
  type = string
}

variable "main-region" {
  type = string
}

variable "env_name" {
  type = string
}

################################################################################
# EKS Cluster Variables
################################################################################


################################################################################
# VPC Variables
################################################################################
variable "private_subnets" {
  description = "Private subnets to create grafana workspace"
  type        = list(string)
}


################################################################################
# Variables from other Modules
################################################################################

variable "sso_admin_group_id" {
  description = "AWS_SSO Admin Group ID"
  type        = string
}

