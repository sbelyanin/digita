job "mongodb-branch-job" {
  datacenters = ["dc1"]
  type = "service"
  group "mongodb-branch-group" {
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
    task "mongodb-branch-task" {
      driver = "docker"
      config {
        image = "mongo:4.1"
        port_map {
          db = 27017
        }
        hostname = "mongodb-branch"
        dns_search_domains = ["service.consul"]
        dns_servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
        volumes = [
          "local/mongodb-branch/data:/data"
        ]
      }
      resources {
        cpu    = "300"
        memory = "300"
        network {
          mbits = 10
          port "db" {}
        }
      }

      service {
        name = "mongodb-branch"
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

