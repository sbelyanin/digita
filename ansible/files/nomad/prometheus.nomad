job "prometheus" {
  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${attr.platform.gce.attr.prometheus}"
    value     = "True"
  }

  group "monitoring" {
    count = 1
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }
    ephemeral_disk {
      size = 300
    }

    task "prometheus" {

      template {
        change_mode = "noop"
        destination = "local/alerts_rule.yml"
        data = <<EOH
---
groups:
- name: prometheus_alerts
  rules:
  - alert: Instance down
    expr: up == 0
    for: 30s
    labels:
      severity: warning
    annotations:
      description: "Instance down."

EOH
      }

      template {
        change_mode = "noop"
        destination = "local/prometheus.yml"
        data = <<EOH
---
global:
  scrape_interval:     5s
  evaluation_interval: 5s

rule_files:
  - "alerts_rule.yml"

alerting:
  alertmanagers:
  - consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services: ['alertmanager']

scrape_configs:
  - job_name: 'nomad_metrics'
    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services: ['nomad-clients', 'nomad']
    relabel_configs:
    - source_labels: ['__meta_consul_tags']
      regex: '(.*)http(.*)'
      action: keep
    scrape_interval: 15s
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']

  - job_name: 'consul_metrics'
    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services: ['consul']
    relabel_configs:
    - source_labels: ['__address__']
      target_label: __address__
      regex: '(.*):(.*)'
      replacement: ${1}:8500
    scrape_interval: 15s
    metrics_path: /v1/agent/metrics
    params:
      format: ['prometheus']

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'alertmanager'
    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services: ['alertmanager']

EOH
      }
      driver = "docker"
      config {
        image = "prom/prometheus:latest"
        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
          "local/alerts_rule.yml:/etc/prometheus/alerts_rule.yml"
#          "/srv//prometheus/tsdb:/prometheus"
        ]
        port_map {
          prometheus_ui = 9090
        }
      }
      resources {
        cpu    = "500"
        memory = "300"
        network {
          mbits = 10
          port "prometheus_ui" {}
        }
      }
      service {
        name = "prometheus"
        tags = [
          "traefik.enable=true",
          "traefik.frontend.entryPoints=https",
          "traefik.frontend.rule=Host:prometheus"
        ]
        port = "prometheus_ui"
        check {
          name     = "prometheus_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}

