job "fluentd-job" {
  datacenters = ["dc1"]
  type = "system"
  group "fluentd-group" {
    count = 1

    restart {
      attempts = 3
      delay    = "20s"
      mode     = "delay"
    }

    task "fluentd-task" {
      driver = "docker"

      config {
        image = "registry.service.consul:5000/fluentd:latest"
        force_pull = true
        port_map {
          fluentd = 24224
        }
      }

      service {
        name = "fluentd"
        tags = [
          "logging"
        ]
        port = "fluentd"
        check {
          type = "tcp"
          interval = "20s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 50
        memory = 100
        network {
          port "fluentd" { 
            static = 24224  
          }
        }
      }
    }
  }
}
