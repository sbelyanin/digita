job "traefik" {
  datacenters = ["dc1"]
  type = "system"
  group "traefik" {
    count = 1
    restart {
      attempts = 5
      interval = "10m"
      delay = "30s"
      mode = "delay"
    }

    task "traefik" {
      artifact {
        source      = "https://github.com/containous/traefik/releases/download/v1.7.10/traefik_linux-amd64"
        destination = "local/traefik"
        mode        = "file"
      }
      driver = "raw_exec"
      config {
        command = "local/traefik"          
        args = [ "--configFile=/srv/traefik/traefik.toml" ]
      }
      resources {
        cpu    = 200 # Mhz
        memory = 300  # MB

        network {
          port "http" {
            static = "80"
          }
          port "https" {
            static = "443"
          }
          port "admin" {
            static = "8080"
          }

        }
      }

      service {
        name = "traefik-ui"
        port = "admin"
        tags = [
          "traefik.enable=true",
          "traefik.frontend.entryPoints=https",
          "traefik.frontend.rule=Host:traefik-ui"
        ]

        check {
          name     = "alive"
          type     = "http"
          path     = "/"
          interval = "120s"
          timeout  = "2s"
        }
      }
    }
  }
}

