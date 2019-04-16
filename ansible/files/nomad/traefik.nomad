job "traefik" {
  datacenters = ["dc1"]
  type = "service"
  group "traefik" {
    count = 1
    restart {
      attempts = 5
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
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

        args = [
          "--web",
          "--consulcatalog",
          "--consulcatalog.endpoint=127.0.0.1:8500",
          "--consul=true",
          "--entrypoints=Name:http Address::9080",
          "--entrypoints=Name:https Address::9443",
          "--entrypoints=Name:traefik Address::9090"
        ]
        
      }

      resources {
        cpu    = 300 # Mhz
        memory = 100  # MB

        network {

          port "http" {
            static = "9080"
          }

          port "https" {
            static = "9443"
          }

          port "admin" {
            static = "9090"
          }

        }
      }
    }
  }
}

