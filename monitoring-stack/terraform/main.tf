terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "docker" {
  ## Windows Docker Desktop
  host = "npipe:////./pipe/docker_engine"
  ## dev box config 
  #"unix:///var/run/docker.sock"
}

# Network for monitoring stack
resource "docker_network" "monitoring" {
  name = "monitoring-net"
}

# Prometheus container
resource "docker_container" "prometheus" {
  name    = "prometheus"
  image   = "prom/prometheus:v3.5.0" // latest stable version as of writing
  restart = "unless-stopped"
  ports {
    internal = 9090
    external = 9090
  }
  networks_advanced {
    name    = docker_network.monitoring.name
    aliases = ["prometheus"]
  }
  # Data persistence (Prometheus default: /prometheus)
  volumes {
    host_path      = abspath("${path.module}/data/prometheus")
    container_path = "/prometheus"
  }
  # Config mount (read-only) (Prometheus default: /etc/prometheus/prometheus.yml)
  volumes {
    host_path      = abspath("${path.module}/prometheus.yml")
    container_path = "/etc/prometheus/prometheus.yml"
    read_only      = true
  }
}

# Grafana container
resource "docker_container" "grafana" {
  name    = "grafana"
  image   = "grafana/grafana-enterprise:11.6" // latest stable version as of writing
  restart = "unless-stopped"
  ports {
    internal = 3000
    external = 3000
  }
  networks_advanced {
    name    = docker_network.monitoring.name
    aliases = ["grafana"]
  }
  # Data persistence (Grafana default: /var/lib/grafana)
  volumes {
    host_path      = abspath("${path.module}/data/grafana")
    container_path = "/var/lib/grafana"
  }
  # Optional: Provisioning for datasources/dashboards
  volumes {
    host_path      = abspath("${path.module}/grafana-provisioning")
    container_path = "/etc/grafana/provisioning"
    read_only      = true
  }
  depends_on = [docker_container.prometheus]
}

# Alertmanager container
resource "docker_container" "alertmanager" {
  name    = "alertmanager"
  image   = "prom/alertmanager:v0.28.1"
  restart = "unless-stopped"
  mounts {
    target = "/etc/alertmanager"
    source = "${abspath(path.module)}/alertmanager"
    type   = "bind"
  }
  ports {
    internal = 9093
    external = 9093
  }
  networks_advanced {
    name    = docker_network.monitoring.name
    aliases = ["alertmanager"]
  }
  # Data persistence
  volumes {
    host_path      = abspath("${path.module}/data/alertmanager/")
    container_path = "/alertmanager"
  }
  # Config (read-only)
  volumes {
    host_path      = abspath("${path.module}/alertmanager.yml") #these two create the "/alertmanager.yml" item as a directory in the terraform folder in the repo
    container_path = "/etc/alertmanager/alertmanager.yml"
    read_only      = true
  }
  depends_on = [docker_container.prometheus]
}

# Python based metrics service container
resource "docker_container" "metrics-service" {
  name    = "metrics-service"
  image   = "my-metrics-service:latest" #"python:3.12-slim" opting for baked image
  restart = "unless-stopped"
  #command = ["sh", "-c", "pip install -r /metrics-service/requirements.txt && python /metrics-service/app.py"] opting for baked image
  ports {
    internal = 8000
    external = 8000
  }
  networks_advanced {
    name    = docker_network.monitoring.name
    aliases = ["metrics-service"]
  }
  # Mount source only if you want live local development - considered a dev only feature, not something wanted for production
  # volumes {
  #   host_path      = abspath("C:/Users/Jonathan/source/repos/IaC-Monitoring/monitoring-stack/metrics-service")
  #   container_path = "/app"
  # }
  # volumes {
  #   host_path      = "${path.module}/metrics-service"
  #   container_path = "/metrics-service"
  # }
}

