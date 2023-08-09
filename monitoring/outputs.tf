################################################################################
# Prometheus Workspace
################################################################################

output "prometheus_workspace_arn" {
  description = "Amazon Resource Name (ARN) of the workspace"
  value       = module.prometheus.workspace_arn
}

output "prometheus_workspace_id" {
  description = "Identifier of the workspace"
  value       = module.prometheus.workspace_id
}

output "workspace_prometheus_endpoint" {
  description = "Prometheus endpoint available for this workspace"
  value       = module.prometheus.workspace_prometheus_endpoint
}

################################################################################
# Grafana Workspace
################################################################################

output "grafana_workspace_arn" {
  description = "The Amazon Resource Name (ARN) of the Grafana workspace"
  value       = module.managed_grafana.workspace_arn
}

output "grafana_workspace_id" {
  description = "The ID of the Grafana workspace"
  value       = module.managed_grafana.workspace_id
}

output "grafana_workspace_endpoint" {
  description = "The endpoint of the Grafana workspace"
  value       = module.managed_grafana.workspace_endpoint
}

output "workspace_grafana_version" {
  description = "The version of Grafana running on the workspace"
  value       = module.managed_grafana.workspace_grafana_version
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.managed_grafana.security_group_id
}
