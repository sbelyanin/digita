job "gitlab-job" {
  datacenters = ["dc1"]
  type = "service"
  group "gitlab-group" {
    count = 1
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }
    task "gitlab-job" {
      driver = "docker"
      config {
        image = "gitlab/gitlab-ce:latest"
        storage_opt = {
          size = "8G"
        }
        port_map {
          http = 80
          https = 443
          ssh = 22
        }
      }
      resources {
 
        cpu    = 1000 # 500 MHz
        memory = 3000  # 256MB

        network {
          mbits = 100
          port "http" {}
          port "https" {}
          port "ssh" {}
        }
      }
      service {
        name = "gitlab"
        tags = ["urlprefix-/gitlab"]
        port = "http"
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

