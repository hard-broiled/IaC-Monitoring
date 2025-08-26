terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Network for monitoring stack
resource "docker_network" "monitoring" {
  name = "monitoring-net"
}

# Prometheus container
resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = "prom/prometheus:latest"
  ports {
    internal = 9090
    external = 9090
  }
  networks_advanced {
    name = docker_network.monitoring.name
  }
  volumes {
    host_path      = "${path.module}/prometheus.yml"
    container_path = "/etc/prometheus/prometheus.yml"
  }
}

# Grafana container
resource "docker_container" "grafana" {
  name  = "grafana"
  image = "grafana/grafana:latest"
  ports {
    internal = 3000
    external = 3000
  }
  networks_advanced {
    name = docker_network.monitoring.name
  }
}

# Alertmanager container
resource "docker_container" "alertmanager" {
  name  = "alertmanager"
  image = "prom/alertmanager:latest"
  ports {
    internal = 9093
    external = 9093
  }
  networks_advanced {
    name = docker_network.monitoring.name
  }
}
