job "crawler-app-release-job" {
  datacenters = ["dc1"]
  type = "service"
  group "crawler-app-release-group" {
    count = 1
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    task "crawler-app-release-task" {
      driver = "docker"
      config {
        image = "registry.service.consul:5000/crawler_app:release"
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
               RMQ_PORT="{{range service "rabbitmq"}}{{.Address}}{{end}}"
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
        name = "crawler-app"
        port = "prom_metr"
        check {
          type     = "tcp"
          interval = "20s"
          timeout  = "2s"
        }
      }
    }
  }
}
