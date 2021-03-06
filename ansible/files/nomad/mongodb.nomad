job "mongodb-job" {
  datacenters = ["dc1"]
  type = "service"
  constraint {
    attribute = "${attr.platform.gce.attr.mongodb}"
    value     = "True"
  }
  group "mongodb-group" {
    count = 1
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    task "mongodb-task" {
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
          "/srv/mongodb/data:/data"
        ]
      }
      resources {
        cpu    = "500"
        memory = "300"
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

