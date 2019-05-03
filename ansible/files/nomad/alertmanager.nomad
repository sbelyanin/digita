job "alertmanager-job" {
  datacenters = ["dc1"]
  type = "service"

  group "alertmanager-group" {
    count = 1
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }
    task "alertmanager-task" {
      driver = "docker"
      config {
        image = "prom/alertmanager:latest"
        port_map {
          alertmanager_ui = 9093
        }
      }
      resources {
        cpu    = "100"
        memory = "100"
        network {
          mbits = 10
          port "alertmanager_ui" {}
        }
      }
      service {
        name = "alertmanager"
        tags = [
          "traefik.enable=true",
          "traefik.frontend.entryPoints=https",
          "traefik.frontend.rule=Host:alertmanager"
        ]
        port = "alertmanager_ui"
        check {
          name     = "alertmanager_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}

