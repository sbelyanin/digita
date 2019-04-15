job "nginx-job" {
  datacenters = ["dc1"]
  type = "service"
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
    task "nginx-job" {
      driver = "docker"
      config {
        image = "nginx:latest"
        port_map {
          lb = 80
        }
      }
      resources {
        network {
          mbits = 10
          port "lb" {}
        }
      }
      service {
        name = "nginx"
        tags = ["urlprefix-/"]
        port = "lb"
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

