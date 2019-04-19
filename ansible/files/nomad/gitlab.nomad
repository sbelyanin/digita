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

    task "gitlab" {
      driver = "docker"

      affinity {
        attribute = "${meta.gitlab}"
        value     = "yes"
        weight    = 100
      }

      config {
        image = "gitlab/gitlab-ce:latest"
        port_map {
          http = 80
          https = 443
          ssh = 22
        }
        hostname = "gitlab"
        
        dns_servers = [
          "consul.service.lab.consul"
        ]

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
           }
          port "https" {
           }
          port "ssh" {
            static = "1022"
           }
        }
      }

      service {
        name = "gitlab-ui"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.frontend.entryPoints=https",
          "traefik.frontend.rule=Host:gitlab" 
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

