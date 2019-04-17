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
    ephemeral_disk {
      size = 6000
    }
    task "gitlab-job" {
      driver = "docker"
      config {
        image = "gitlab/gitlab-ce:latest"
        port_map {
          http = 80
          https = 443
          ssh = 22
        }
        hostname = "gitlab"
        volumes = [
          "/srv/gitlab/config:/etc/gitlab",
          "/srv/gitlab/logs:/var/log/gitlab",
          "/srv/gitlab/data:/var/opt/gitlab"
        ]
      }
      resources {
        cpu    = "1000"
        memory = "4000"
        network {
          mbits = 10
          port "http" {
            static = "1080"
           }
          port "https" {
            static = "1443"
           }
          port "ssh" {
            static = "1022"
           }
        }
      }

      service {
        name = "gitlab-ui-prefix"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.frontend.entryPoints=http",
          "traefik.frontend.rule=Host:localhost",
          "traefik.frontend.rule=PathPrefixStrip: /gitlab"
        ]

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

