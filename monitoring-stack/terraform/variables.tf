variable "prometheus_image" {
  default = "prom/prometheus:latest"
}

variable "grafana_image" {
  default = "grafana/grafana:latest"
}

variable "alertmanager_image" {
  default = "prom/alertmanager:latest"
}
