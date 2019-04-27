job "test" {
  datacenters = ["dc1"]
  type = "batch"
  constraint {
    attribute = "${attr.platform.gce.attr.gitlab}"
    value     = "True"
  }
  group "test" {
    count = 1
    restart {
      attempts = 5
      interval = "10m"
      delay = "30s"
      mode = "delay"
    }

    task "test" {
      driver = "raw_exec"
      config {
        command = "/bin/bash"
        args = ["-c", "cat /srv/test.txt"]
      }


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
        destination = "/srv/test.txt"
      }

      resources {
        cpu    = 100 # Mhz
        memory = 100  # MB
        network {
          mbits = 10
          port "uptime1" {}
        }
      }
    }
  }
}

