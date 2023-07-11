################################################################################
# General Variables from root module
################################################################################

variable "profile" {
  type    = string
  default = "default"
}

variable "main-region" {
  type    = string
  default = "us-east-2"
}

variable "env_name" {
  type    = string
  default = "dev"
}

################################################################################
# EKS Cluster Variables
################################################################################

variable "cluster_name" {
  type    = string
  default = "tf-cluster"
}

variable "cluster_endpoint" {
  type        = string
  sensitive   = true
  description = "The cluster endpoint"
}

variable "cluster_certificate_authority_data" {
  type        = string
  sensitive   = true
  description = "The Cluster certificate data"
}

variable "oidc_provider_arn" {
  description = "OIDC Provider ARN used for IRSA "
  type        = string
  sensitive   = true
}

################################################################################
# VPC Variables
################################################################################

variable "vpc_id" {
  description = "VPC ID which Load balancers will be  deployed in"
  type        = string
}
