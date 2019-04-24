job "crawler-master-job" {
  datacenters = ["dc1"]
  type = "service"
  group "crawler-master-group" {
    count = 1
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    task "crawler-app-master" {
      driver = "docker"
      config {
        image = "registry.service.consul:5000/crawler_app:master"
        port_map {
          prom_metr = 8000
        }
        dns_search_domains = ["service.consul"]
        dns_servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
      }
      template {
        data = <<-EOF
               MONGO="{{range service "mongodb"}}{{.Address}}{{end}}"
               MONGO_PORT="{{range service "mongodb"}}{{.Port}}{{end}}"
               RMQ_HOST="{{range service "rabbitmq"}}{{.Address}}{{end}}"
               EOF

        destination = "secrets/file.env"
        env         = true
      }
      resources {
        cpu    = "500"
        memory = "200"
        network {
          mbits = 10
          port "prom_metr" {}
        }
      }  
      service {
        name = "crawler-app-master"
        port = "prom_metr"
        check {
          type     = "tcp"
          interval = "20s"
          timeout  = "2s"
        }
      }
    }
    task "crawler-ui-master" {
      driver = "docker"
      config {
        image = "registry.service.consul:5000/crawler_ui:master"
        port_map {
          web = 8000
        }
        dns_search_domains = ["service.consul"]
        dns_servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
      }
      template {
        data = <<-EOF
               MONGO="{{range service "mongodb"}}{{.Address}}{{end}}"
               MONGO_PORT="{{range service "mongodb"}}{{.Port}}{{end}}"
               EOF

        destination = "secrets/file.env"
        env         = true
      }
      resources {
        cpu    = "500"
        memory = "200"
        network {
          mbits = 1
          port "web" {}
        }
      }
      service {
        name = "crawler-ui-master"
        port = "web"
        tags = [
          "traefik.enable=true",
          "traefik.frontend.entryPoints=https",
          "traefik.frontend.rule=Host:crawler-master"
        ]
        check {
          type     = "tcp"
          interval = "20s"
          timeout  = "2s"
        }
      }
    }
  }
}
