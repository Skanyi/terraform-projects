
################################################################################
# Default Variables
################################################################################

variable "profile" {
  type    = string
  default = "kanyi-po"
}

variable "main-region" {
  type    = string
  default = "us-east-2"
}


################################################################################
# EKS Cluster Variables
################################################################################

variable "cluster_name" {
  type    = string
  default = "tf-cluster"
}

variable "rolearn" {
  description = "Add admin role to the aws-auth configmap"
}

################################################################################
# ALB Controller Variables
################################################################################

variable "env_name" {
  type    = string
  default = "dev"
}

