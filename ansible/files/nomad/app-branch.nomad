job "crawler-app-branch-job" {
  datacenters = ["dc1"]
  type = "service"
  group "crawler-app-branch-group" {
    count = 1
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    task "crawler-app-branch-task" {
      driver = "docker"
      config {
        image = "registry.service.consul:5000/crawler_app:branch"
        port_map {
          prom_metr = 8000
        }
        dns_search_domains = ["service.consul"]
        dns_servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
      }
      template {
        data = <<-EOF
               MONGO="{{range service "mongodb-branch"}}{{.Address}}{{end}}"
               MONGO_PORT="{{range service "mongodb-branch"}}{{.Port}}{{end}}"
               RMQ_HOST="{{range service "rabbitmq"}}{{.Address}}{{end}}"
               RMQ_PORT="{{range service "rabbitmq"}}{{.Port}}{{end}}"
               RMQ_QUEUE="urls-branch"
               EOF

        destination = "secrets/file.env"
        env         = true
      }
      resources {
        cpu    = "200"
        memory = "200"
        network {
          mbits = 10
          port "prom_metr" {}
        }
      }  
      service {
        name = "crawler-app-branch"
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
