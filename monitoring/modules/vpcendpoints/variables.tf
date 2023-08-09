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
# VPC Variables
################################################################################

variable "vpc_id" {
  description = "VPC ID which Load balancers will be  deployed in"
  type        = string
}

variable "private_subnets" {
  description = "Private subnets to create grafana workspace"
  type        = list(string)
}

variable "grafana_security_group_id" {
  description = "Grafana Security Group ID"
  type        = string
}

################################################################################
# Variables from other Modules
################################################################################
