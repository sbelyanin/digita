job "rabbitmq-job" {
  datacenters = ["dc1"]
  type = "service"
  group "rabbitmq-group" {
    count = 1
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    ephemeral_disk {
      size = 500
      sticky = true      
    }
    task "rabbitmq" {
      driver = "docker"
      config {
        image = "rabbitmq:3-management"
        port_map {
          web = 15672
          amqp = 5672
        }
        hostname = "rabbitmq"
        dns_search_domains = ["service.consul"]
        dns_servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
      }
      resources {
        cpu    = "1000"
        memory = "450"
        network {
          mbits = 10
          port "web" {}
          port "amqp" {} 
        }
      }

      service {
        name = "rabbitmq"
        port = "amqp"
        check {
          type     = "tcp"
          interval = "20s"
          timeout  = "2s"
        }
      } 
      service {
        name = "rabbitmq-ui"
        port = "web"
        tags = [
          "traefik.enable=true",
          "traefik.frontend.entryPoints=https",
          "traefik.frontend.rule=Host:rabbitmq"
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

