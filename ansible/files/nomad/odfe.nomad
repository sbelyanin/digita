job "odfe-job" {
  datacenters = ["dc1"]
  type = "service"
  constraint {
    attribute = "${attr.platform.gce.attr.efk}"
    value     = "True"
  }
  group "odfe-group" {
    count = 1
    restart {
      attempts = 2
      interval = "10m"
      delay = "15s"
      mode = "fail"
    }

    task "odfe-task" {
      driver = "docker"
      config {
        image = "amazon/opendistro-for-elasticsearch:0.9.0"
        port_map {
          http = 9200
          perf = 9600
        }

        env {
          cluster.name = "odfe-cluster"
          bootstrap.memory_lock = "true"
          "ES_JAVA_OPTS" = "-Xms512m -Xmx512m" 
        }
        
        dns_servers = [
          "172.17.0.1", "8.8.8.8", "8.8.4.4"
        ]

        volumes = [
          "/srv/odfe/data:/usr/share/elasticsearch/data"
        ]
      }
      resources {
        cpu    = "200"
        memory = "1500"
        network {
          mbits = 10
          port "http" {
           }
          port "perf" {
           }
        }
      }

      service {
        name = "odfe"
        port = "http"
        check {
          type     = "tcp"
          interval = "120s"
          timeout  = "2s"
        }
      }

    }
  }
}

