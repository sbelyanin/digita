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
      driver = "docker"
      config {
        image = "grafana/grafana:master"
        port_map {
          graf_ui = 3000
        }
#        volumes = [
#          "/srv/grafana/storage:/var/lib/grafana", 
#          "/srv/grafana/etc:/etc/grafana"
#        ]
        dns_search_domains = ["service.consul"]
        dns_servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
      }
      template {
        data = <<-EOF
               GF_SERVER_ROOT_URL="https://grafana/"
               GF_SECURITY_ADMIN_PASSWORD="GraFanA"
               EOF
        destination = "secrets/file.env"
        env         = true
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
