job "runner-job" {
  datacenters = ["dc1"]
  type = "service"
  group "runner-group" {
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
    task "runner" {
      driver = "docker"
      config {
        image = "gitlab/gitlab-runner:latest"
        dns_search_domains = ["service.consul"]
        dns_servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
         ]

      }
      env {
        "REGISTRY_HTTP_TLS_CERTIFICATE" = "/certs/registry.crt",
        "REGISTRY_HTTP_TLS_KEY" = "/certs/registry.key"
      }

      resources {
        network {
          mbits = 10
        }
      }
      service {
        name = "registry"
        port = "reg_port"
        check {
          type     = "tcp"
          interval = "20s"
          timeout  = "2s"
        }
      }
    }
  }
}

