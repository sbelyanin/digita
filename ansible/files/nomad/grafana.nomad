job "grafana-job" {
  datacenters = ["dc1"]
  type = "service"
  constraint {
    attribute = "${attr.platform.gce.attr.prometheus}"
    value     = "True"
  }
  group "grafana-group" {
    count = 1
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    task "grafana-task" {
      artifact {
        source      = "https://grafana.com/api/dashboards/179/revisions/7/download"
        destination = "local/179"
      }

      artifact {
        source      = "https://grafana.com/api/dashboards/1860/revisions/13/download"
        destination = "local/1860"
      }

      template {
        change_mode = "noop"
        destination = "local/datasource.yml"
        data = <<EOH
apiVersion: 1
datasources:
- name: Prometheus
  type: prometheus
  is_default: 'true'
  access: proxy
  orgId: 1
  url: 'http://prometheus.service.consul:{{range service "prometheus"}}{{.Port}}{{end}}'
  editable: true
  version: 1
EOH
      }
      template {
        change_mode = "noop"
        destination = "local/dashboard.yml"
        data = <<EOH
apiVersion: 1
providers:
- name: 'Prometheus'
  orgId: 1
  folder: ''
  type: file
  disableDeletion: false
  editable: true
  options:
    path: /etc/grafana/provisioning/dashboards
EOH
      }

      template {
        data = <<-EOF
               GF_SERVER_ROOT_URL="https://grafana/"
               GF_SECURITY_ADMIN_PASSWORD="GraFanA"
               GF_USERS_ALLOW_SIGN_UP="false"
               EOF
        destination = "secrets/file.env"
        env         = true
      }

      driver = "docker"
      config {
        image = "grafana/grafana:master"
        port_map {
          graf_ui = 3000
        }
        volumes = [
           "local/datasource.yml:/etc/grafana/provisioning/datasources/datasource.yml",
           "local/dashboard.yml:/etc/grafana/provisioning/dashboards/dashboard.yml",           
           "local/179/download:/etc/grafana/provisioning/dashboards/dockerhost.json"
#           "local/1860/download:/etc/grafana/provisioning/dashboards/nodeexporter.json"
#          "/srv/grafana/storage:/var/lib/grafana", 
#          "/srv/grafana/etc:/etc/grafana"
        ]
        dns_search_domains = ["service.consul"]
        dns_servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
      }
      resources {
#        cpu    = "500"
#        memory = "300"
        network {
          mbits = 10
          port "graf_ui" {}
        }
      }  
      service {
        name = "grafana-ui"
        port = "graf_ui"
        tags = [
          "traefik.enable=true",
          "traefik.frontend.entryPoints=https",
          "traefik.frontend.rule=Host:grafana"
        ]
        check {
          type     = "tcp"
          interval = "20s"
          timeout  = "2s"
        }
      }
    }
  }
}
