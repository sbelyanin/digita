job "hashi-ui" {
  datacenters = ["dc1"]
  type = "service"
  group "hashi" {
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


    task "hashi-ui" {

      artifact {
        source      = "https://github.com/jippi/hashi-ui/releases/download/v1.0.0/hashi-ui-linux-amd64"
        destination = "local/hashi-ui"
        mode        = "file"
      }

      driver = "raw_exec"

      config {
        command = "local/hashi-ui"          

        args = [
          "--nomad-enable",
          "--consul-enable",
          "--nomad-address",
          "http://10.132.15.194:4646",
          "--proxy-address",
          "/hashi-ui"
        ]
        
      }
      
      service {
        name = "nomad-ui-prefix"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.frontend.entryPoints=http",
          "traefik.frontend.rule=Host:localhost",
          "traefik.frontend.rule=PathPrefixStrip: /hashi-ui"
        ]
      }

      resources {
        cpu    = 300 # Mhz
        memory = 100  # MB

        network {
          port "http" {
            static = "3000"
          }
        }
      }

    }
  }
}

