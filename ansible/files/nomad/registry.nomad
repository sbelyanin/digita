job "registry-job" {
  datacenters = ["dc1"]
  type = "service"
  constraint {
    attribute = "${attr.platform.gce.attr.registry}"
    value     = "True"
  }
  group "registry-group" {
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
    task "registry" {
      driver = "docker"
      config {
        image = "registry:2"
        port_map {
          reg_port = 5000
        }
        dns_search_domains = ["service.consul"]
        dns_servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
        hostname = "registry"
        volumes = [
          "/srv/registry/data:/var/lib/registry",
          "/srv/certs/:/certs/:ro"
        ]

      }

      env {
        "REGISTRY_HTTP_TLS_CERTIFICATE" = "/certs/registry.crt",
        "REGISTRY_HTTP_TLS_KEY" = "/certs/registry.key"
      }

      resources {
        network {
          mbits = 10
          port "reg_port" {
            static = "5000"
          }
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

