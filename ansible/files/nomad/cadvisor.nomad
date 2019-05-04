job "cadvisor-job" {
  datacenters = ["dc1"]
  type = "system"
  group "cadvisor-group" {
    count = 1
    restart {
      attempts = 3
      delay    = "20s"
      mode     = "delay"
    }
    task "cadvisor-task" {
      driver = "docker"
      config {
        image = "google/cadvisor:v0.33.0"
        force_pull = true
        volumes = [
          "/:/rootfs:ro",
          "/var/run:/var/run:rw",
          "/sys:/sys:ro",
          "/var/lib/docker/:/var/lib/docker:ro",
          "/cgroup:/cgroup:ro"
        ]
        port_map {
          http = 8080
        }
        logging {
          type = "journald"
          config {
            tag = "CADVISOR"
          }
        }
      }

      service {
        name = "cadvisor"
        tags = [
          "metrics"
        ]
        port = "http"
        check {
          type = "http"
          path = "/metrics/"
          interval = "10s"
          timeout = "2s"
        }
      }

      resources {
        cpu    = 50
        memory = 100

        network {
          port "http" { }
        }
      }
    }
  }
}
