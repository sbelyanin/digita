job "nginx-job" {
  datacenters = ["dc1"]
  type = "service"

#  constraint {
#    attribute = "${attr.platform.gce.attr.prometheus}"
#    value     = "True"
#  }

  group "nginx-group" {
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
    task "nginx" {
      driver = "docker"
      config {
        image = "nginx:latest"
        port_map {
          lb = 80
        }
      dns_search_domains = ["service.consul"]
      dns_servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
      }
      resources {
        network {
          mbits = 10
          port "lb" {}
        }
      }
      service {
        name = "nginx"
        port = "lb"
        tags = [
          "traefik.enable=true",
          "traefik.frontend.entryPoints=https",
          "traefik.frontend.rule=Host:nginx"
        ]
        check {
          name     = "alive"
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}

