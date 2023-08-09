# DRAFT. Not tested yet 

## Deploy AWS Managed Prometheus (AMP) and AWS Managed Grafana (AMG) With Terraform for scalable observibility on EKS Cluster. 

### Prerequisite

Before we proceed deploy AMP and AMG using Terraform, there are a few commands or tools you need to have in the server where you will be executing the terraform scripts on.

    1. awscli - aws-cli/2.12.1 Python/3.11.3

    2. go version go1.18.9 linux/amd64

    3. Terraform v1.5.0

    4. kubectl - Client Version: v1.23.17-eks

    5. helm - v3.8.0

### Assumptions

The following details makes the following assumptions.

    You have aws cli configured

    You have created s3 bucket that will act as the backend of the project. 

## Quick Setup

Clone the repository:

    git clone https://github.com/Skanyi/terraform-projects.git

Change directory;

    cd terraform-projects/monitoring

Update the `backend.tf` and update the s3 bucket and the region of your s3 bucket. Update the profile if you are not using the default profile. 

Update the `variables.tf` profile variable if you are not using the default profile. 

Update the `secret.tfvars` file with the output values of the [Setting up EKS with Terraform, Helm and a Load balance]()

Format the the project

    terraform fmt

Initialize the project to pull all the moduels used

    terraform init

Validate that the project is correctly setup. 

    terraform validate

Run the plan command to see all the resources that will be created

    terraform plan --var-file="secret.tfvars

When you ready, run the apply command to create the resources. 

    terraform apply --var-file="secret.tfvars


## Detailed Setup Steps. 

When the above setup is done, we are now ready to deploy AMP and AMG in our previous created cluster. If you have not created the cluster, follow the steps outlined here # Setting up EKS with Terraform, Helm and a Load balancer In this step.

### Deploy AWS Managed Service for Grafana (AMG)

Before creating the AMG, we need to created 

Ensure AWS-SSO is enabled

Getting started with Amazon Managed Grafana [https://docs.aws.amazon.com/grafana/latest/userguide/getting-started-with-AMG.html]

AWS IAM Identity Center (successor to AWS Single Sign-On)

The authentication providers for the workspace. Valid values are AWS_SSO, SAML, or both

1. Create the AMG using the [AWS Managed Service for Grafana (AMG) Terraform module] https://registry.terraform.io/modules/terraform-aws-modules/managed-service-grafana/aws/latest

    ```
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
        "group_ids" = [var.sso_admin_group_id]
        }
    }

    tags = {
        Terraform   = "true"
        Environment = var.env_name
    }
    }
    ```


### Deploy AWS Managed Service for Prometheus (AMP) 

Install the EBS CSI controller Addon

EBS CSI driver entirely from Terraform on AWS EKS
 
eks_managed_node_group_defaults = { 
    # Needed by the aws-ebs-csi-driver 
    iam_role_additional_policies = { 
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" 
    } 
}

aws-ebs-csi-driver = {
    most_recent = true
}


1.  Create the AWS Managed Service for Prometheus (AMP) Terraform module https://registry.terraform.io/modules/terraform-aws-modules/managed-service-prometheus/aws/latest

    ```
    module "prometheus" {
    source = "terraform-aws-modules/managed-service-prometheus/aws"

    workspace_alias  = "eks-workspace"
    create_workspace = true

    providers = {
        aws = aws.us-east-2
    }

    alert_manager_definition = <<-EOT
    alertmanager_config: |
        route:
        receiver: 'default'
        receivers:
        - name: 'default'
    EOT

    rule_group_namespaces = {
        first = {
        name = "rule-01"
        data = <<-EOT
        groups:
            - name: test
            rules:
            - record: metric:recording_rule
                expr: avg(rate(container_cpu_usage_seconds_total[5m]))
        EOT
        }
        second = {
        name = "rule-02"
        data = <<-EOT
        groups:
            - name: test
            rules:
            - record: metric:recording_rule
                expr: avg(rate(container_cpu_usage_seconds_total[5m]))
        EOT
        }
    }
    }
    ```

2. Namespace - Create a namespace where we are going to deploy the prometheus server in the EKS Cluster.

    ```
    resource "kubernetes_namespace" "prometheus-namespace" {
    metadata {
        annotations = {
        name = "monitoring"
        }

        labels = {
        application = "monitoring"
        }

        name = "monitoring"
    }
    }
    ```

3. Role - Create a role that we are going to annotate the Service Account used by the prometheus server.

    ```
    module "prometheus_role" {
    source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

    role_name                                        = "${var.env_name}_prometheus"
    attach_amazon_managed_service_prometheus_policy  = true
    amazon_managed_service_prometheus_workspace_arns = [module.prometheus.workspace_arn]

    oidc_providers = {
        main = {
        provider_arn               = var.oidc_provider_arn
        namespace_service_accounts = ["${kubernetes_namespace.prometheus-namespace.metadata[0].name}:amp-iamproxy-ingest-role"]
        }
    }

    }
    ```

4. Service Account - Create a service account that the prometheus server is going to use to get access the AMP service. 

    ```
    resource "kubernetes_service_account" "service-account" {
    metadata {
        name      = "amp-iamproxy-ingest-role"
        namespace = kubernetes_namespace.prometheus-namespace.metadata[0].name
        labels = {
        "app.kubernetes.io/name" = "prometheus"
        }
        annotations = {
        "eks.amazonaws.com/role-arn"               = module.prometheus_role.iam_role_arn
        "eks.amazonaws.com/sts-regional-endpoints" = "true"
        }
    }
    }
    ```

5. Deployment - Install prometheus server with Helm. 

    `templates/amp_ingest_override_values.yaml` can be customized to meet your configuration desire for the AMP server deployment. 

    ```
    resource "helm_release" "prometheus" {
    name       = "prometheus-community"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart      = "prometheus"
    version    = "23.1.0"
    namespace  = kubernetes_namespace.prometheus-namespace.metadata[0].name
    depends_on = [
        kubernetes_service_account.service-account
    ]

    values = [
        "${file("${path.module}/templates/amp_ingest_override_values.yaml")}"
    ]

    set {
        name  = "server.remoteWrite[0].url"
        value = "${module.prometheus.workspace_prometheus_endpoint}api/v1/remote_write"
    }

    set {
        name  = "server.remoteWrite[0].sigv4.region"
        value = var.main-region
    }

    }
    ```



When the above is done, use the following commands to confirm if the prometheus server was deployed successfully.

    kubectl get all -n monitoring


### Deploy VPC endpoints

1. Security Group - Create a security group that will be attached to the VPC Endpoints. 

    ```
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
    ```

2. Prometheus VPC Endpoint - Create the Prometheus VPC Endpoint

    ```
    resource "aws_vpc_endpoint" "prometheus" {
    vpc_id            = var.vpc_id
    provider          = aws.us-east-2
    service_name      = "com.amazonaws.us-east-2.aps-workspaces"
    vpc_endpoint_type = "Interface"

    security_group_ids = [
        aws_security_group.allow_tls_grafana.id,
    ]

    subnet_ids = var.private_subnets
    }
    ```

### Access the Grafana workspace and create 

Add prometheus as datasource

Create a sample dashboard


Should look like something below. 

![Kubernetes EKS Cluster (Prometheus)](assets/Kubernetes-Ingress-Loadbalancer.png " Deploy AWS Managed Prometheus (AMP) and AWS Managed Grafana (AMG) With Terraform for scalable observibility on EKS Cluster")



