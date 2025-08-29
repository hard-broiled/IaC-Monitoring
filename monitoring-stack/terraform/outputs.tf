output "prometheus_container" {
  value = docker_container.prometheus.name
}

output "grafana_container" {
  value = docker_container.grafana.name
}

output "alertmanager_container" {
  value = docker_container.alertmanager.name
}
