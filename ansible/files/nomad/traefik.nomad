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
      template {
        data = <<EOH
defaultEntryPoints = ["https","http"]

[entryPoints]
  [entryPoints.http]
  address = ":80"
#    [entryPoints.http.redirect]
#     entryPoint = "https"
  [entryPoints.https]
  address = ":443"
    [entryPoints.https.tls]
      [entryPoints.https.tls.defaultCertificate]
        certFile = "/srv/certs/traefik.crt"
        keyFile = "/srv/certs/traefik.key"
  [entryPoints.api]
  address = ":8080"


[docker]
endpoint = "unix:///var/run/docker.sock"
domain = "docker.localhost"
watch = true
exposedbydefault = false

[api]
entrypoint = "api"

[consul]
endpoint = "consul.service.consul:8500"
watch = true
prefix = "traefik"

[consulCatalog]
endpoint = "consul.service.consul:8500"
        EOH
        destination = "local/traefik.toml"
      }

      config {
        command = "local/traefik"          
        args = [ "--configFile=local/traefik.toml" ]
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

