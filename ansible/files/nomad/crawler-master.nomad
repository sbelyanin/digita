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
    ephemeral_disk {
      size = 500
      sticky = true
      
    }

    task "crawler-master-app" {
      driver = "docker"
      config {
        image = "mongo:4.1"
        port_map {
          db = 27017
        }
        hostname = "mongodb"
        dns_search_domains = ["service.consul"]
        dns_servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
        volumes = [
          "local/mongodb/data:/data"
        ]
      }





    }
    task "crawler-master-ui" {
    }
    task "crawler-master-rabbitmq" {
    }
    task "crawler-master-mongodb" {
      driver = "docker"
      config {
        image = "mongo:4.1"
        port_map {
          db = 27017
        }
        hostname = "mongodb"
        dns_search_domains = ["service.consul"]
        dns_servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
        volumes = [
          "local/mongodb/data:/data"
        ]
      }
      resources {
        cpu    = "500"
        memory = "500"
        network {
          mbits = 10
          port "db" {}
        }
      }

      service {
        name = "mongodb"
        port = "db"
        check {
          type     = "tcp"
          interval = "20s"
          timeout  = "2s"
        }
      }
    }
  }
}

